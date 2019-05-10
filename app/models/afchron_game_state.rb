class AfchronGameState < ParticipantState
  aasm column: 'aasm_state' do
    state :none, initial: true
    state :waiting_asked
    state :waiting_number
    state :waiting_for_survey

    event :ask_to_play do
      transitions from: :none, to: :waiting_asked
    end

    event :play do
      transitions from: :asked_to_play, to: :waiting_number
    end

    event :survey do
      transitions from: :waiting_number, to: :waiting_for_survey
    end

    event :reset do
      transitions to: :none
    end
  end

  def set_defaults!
    self.game_count = 0
    self.game_time = nil
    self.measure_with_link = true # TODO - should be survey-dependent
    self.result_pool = generate_result_pool
    self.results = []
    self.game_balance = 0
    # Current schedule day id
    self.game_current_day = nil
    # Hash of schedule_day ids that contains if they won or lost
    self.game_completed = {}
  end

  def generate_result_pool
    # 10 results, half wins. Do not allow 3 losses in a row.
    available = [true, true, true, true, true, false, false, false, false, false]
    pool = nil
    def pool_is_fair pool
      return false unless pool
      loss_streak = 0
      last = true
      pool.each do |x| 
        if not x and x == last then
          loss_streak += 1
        end
        last = x
      end
      loss_streak < 2
    end
    while not (pool_is_fair pool)
      pool = available.sample(available.length)
    end
    pool
  end

  def time_for_game participant, day
    # Does participant have a game start time for this day?
    # If not, decide when game prompt should start today
    time = game_time
    if time.nil? then
      # pick a time in first 70% of time range 
      time = day.starts_at + (day.day_length * 0.7 * rand)
      self.game_time = time
    end
    time
  end

  def game_could_start!
    # Ask the participant if they want to play
    ask_to_play!
    self.delay(run_at: Time.now + 10.minutes).game_timed_out! participant
    return "Do you have time to play a game? (Reply 'yes' if so, no reply is needed if not)", Time.now
  end

  def game_timed_out!
    case current_state.to_s
    when 'waiting_asked', 'waiting_number' then
      # Just retrigger later today, they didn't respond
      self.game_times[game_current_day] = Time.now + 30.minutes
      participant.survey.schedule_participant! participant
    end
  end

  def game_begin!
    # Participant said yes, begin the game
    # TODO: set game_current_day?
    participant.state['game_current_day'] = day_id
    participant.state['game'] = 'waiting_number'
    participant.state['game_count'] += 1
    self.delay(run_at: Time.now + 10.minutes).game_timed_out! participant
    message = "We generated a number between 1 and 9. Guess if it's lower or higher than 5. Reply 'high' or 'low'."
    return message, Time.now
  end

  def game_send_result! day, guessed_high
    # Participant picked high or low... tell them what they won, Jim!
    self.game_survey_count = 0

    # store if they won or not
    winner = self.result_pool.shift
    self.results.push winner
    # yes there's probably a fancy way to xor this together but we have to 
    # pick a number that seems reasonable
    number =
      if winner then
        if guessed_high then
          rand(4) + 6
        else
          rand(4) + 1
        end
      else
        if guessed_high then
          rand(4) + 1
        else
          rand(4) + 6
        end
      end

    # also store this day as completed
    self.game_completed[self.game_current_day] = winner
    self.game_balance += winner ? 10 : -5

    # We go into gather data mode
    self.game_gather_data!

    message =
      "The number was #{number}. " +
      (winner ? "You guessed right! $10 has been added to your account." : "You guessed wrong! $5 has been removed from your account.")
    return message, Time.now
  end

  def game_gather_data!
    survey!
    game_survey_count += 1
    if game_survey_count >= 8 then
      reset!
    end
    # sample time should be 10-15 minutes from now
    time = Time.now + (10 + rand(5)).minutes

    # Timeout after another chunk of minutes if no response, prompt again
    timeout = time + (10 + rand(5)).minutes
    self.delay(run_at: timeout).game_gather_data_again! game_survey_count, participant.id
    if measure_with_link then
      return "Please take this short survey now (sent at {{sent_time}}): {{redirect_link}}", time
    else
      return "How do you feel on a scale of 1 to 10?", time
    end
  end

  def game_gather_data_again! count, participant_id
    # re-ask if they didn't respond last time
    ppt = Participant.find(participant_id)
    if self.game_survey_count == count then
      self.game_gather_data!
    end
  end

  def participant_message message
    day = participant.schedule_days.running_day
    state = self.current_state.to_s
    if state =~ /^waiting_asked/ then
      # We asked if they wanted to start a game
      if message =~ /yes/i then
        do_message!(day, *game_begin!)
        self.participant.save!
      elsif message =~ /no/i then
        day_id = self.game_current_day
        self.game_times[day_id] = Time.now + 30.minutes
        self.participant.save!
      end
    elsif state =~ /^waiting_number/ then
      if message =~ /high|low/i then
        guessed_high = message =~ /high/i
        self.do_message!(day, *game_send_result!(day, guessed_high))
        self.participant.save!
      else
        self.do_message!(day, "You need to pick 'high' or 'low'", Time.now)
      end
    elsif state =~ /^gather_data/ then
      if message =~ /\d+/ then
        self.game_response[day_id] ||= []
        self.game_response[day_id].push message
      end
      self.participant.save!
    else
      logger.warning("Got unexpected participant message #{message} from participant #{participant.id} in game state #{self.inspect}")
    end
  end

  def action_for_day! day
    current = self.current_state.to_s

    if current =~ /^waiting/ then
      # Don't start any new actions if waiting for response
      return false
    end

    today_game_time = self.time_for_game(self.participant, day)

    message_text, scheduled_at = 
      if current == "none" and
        Time.now > today_game_time and
        not self.game_completed.include? day then
        # TODO: This should trigger on a postback from Qualtrics,
        # when we know they finished a default survey
        # ... otherwise, this gets called too often after a timeout
        self.game_could_start!
      else
        case current
        when 'waiting_for_survey'
          self.game_gather_data!
        else
          # The default question
          [ "Please take this survey now (sent at {{sent_time}}): {{redirect_link}}",
            day.random_time_for_next_question ]
        end
      end

    self.participant.save!
    return self.do_message! day, message_text, scheduled_at
  end

  def do_message! day, message_text, scheduled_at
    message = day.scheduled_messages.build(message_text: message_text, scheduled_at: scheduled_at)
    message.save!
    Rails.logger.debug("Scheduled #{message.inspect}")
    ParticipantTexter.delay(run_at: message.scheduled_at).deliver_scheduled_message!(message.id)
    return message
  end
end
