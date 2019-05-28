class AfchronGameState < ParticipantState
  belongs_to :participant
  aasm column: 'aasm_state' do
    state :none, initial: true
    state :waiting_asked
    state :waiting_number
    state :waiting_for_survey

    event :ask_to_play do
      transitions from: :none, to: :waiting_asked
    end

    event :play do
      transitions from: :waiting_asked, to: :waiting_number
    end

    event :survey do
      transitions from: :waiting_number, to: :waiting_for_survey
    end

    event :timeout do
      transitions from: [:waiting_asked, :waiting_number], to: :none
    end

    event :refuse_to_play do
      transitions from: [:waiting_asked], to: :none
    end

    event :reset do
      transitions to: :none
    end
  end

  def set_defaults!
    self.state["game_time"] = nil
    self.state["result_pool"] = generate_result_pool
    self.state["results"] = []
    self.state["game_balance"] = 0
    self.state["game_completed_results"] = [] # List of results
    self.state["game_completed_dayid"] = [] # List of day ids
    self.state["game_completed_time"] = [] # List of completed times
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

  def get_game_time
    time = self.state["game_time"]
    if time.kind_of? Time
      time
    elsif time.nil? or time == ""
      nil
    else
      Time.parse time.to_s
    end
  end

  def get_day
    day = participant.schedule_days.running_day
    if not day
      day = participant.survey.advance_to_day_with_time_for_message! participant
    end
    day
  end

  def time_for_game participant
    day = get_day
    # Does participant have a game start time for this day?
    # If not, decide when game prompt should start today
    time = get_game_time
    if time.nil? then
      # pick a time in first 60% of time range 
      time = day.starts_at + (day.day_length * 0.6 * rand)
      self.state["game_time"] = time
    end
    time
  end

  def game_could_start!
    # Ask the participant if they want to play
    ask_to_play!
    self.delay(run_at: Time.now + 30.minutes).do_timeout!
    return "Do you have time to play a game? (Reply 'yes' if so, no reply is needed if not)", Time.now + 15.minutes
  end

  def do_timeout!
    case aasm_state.to_s
    when 'waiting_asked', 'waiting_number' then
      # Just retrigger later today, they didn't respond
      self.timeout
      self.state["game_time"] = Time.now + 30.minutes
      self.save!
      self.participant.survey.schedule_participant! self.participant
    when 'waiting_survey' then
      # This is not actually called by production code, but is useful for the simulator
      ppt.participant_state.game_gather_data!
    end
  end

  def game_delay!
    next_game = Time.now + (25 + rand(10)).minutes
    self.refuse_to_play
    self.state[:game_time] = next_game
    self.save!
    self.delay(run_at: next_game).take_action!
  end

  def game_begin!
    # Participant said yes, begin the game
    self.play!
    self.delay(run_at: Time.now + 10.minutes).do_timeout!
    message = "We generated a number between 1 and 9. Guess if it's lower or higher than 5. Reply 'high' or 'low'."
    return do_message!(message, Time.now)
  end

  def game_send_result! message
    if message =~ /high|low/i then
      guessed_high = message =~ /high/i
    else
      return self.do_message!("You need to pick 'high' or 'low'", Time.now)
    end

    # Participant picked high or low... tell them what they won, Jim!
    self.state["game_survey_count"] = 0

    # Did they win or not?
    winner = self.state["result_pool"].shift

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

    # store this completion as a boolean, by day id, and by time
    self.state["game_completed_results"].push winner
    self.state["game_completed_dayid"].push get_day.id
    self.state["game_completed_time"].push Time.now
    self.state["game_balance"] += winner ? 10 : -5

    # We go into gather data mode
    self.game_gather_data!

    message =
      "The number was #{number}. " +
      (winner ? "You guessed right! $10 has been added to your account." : "You guessed wrong! $5 has been removed from your account.")
    return do_message!(message, Time.now)
  end

  def build_survey_message
    return "Please take this short survey now (sent at {{sent_time}}): {{redirect_link}}"
  end

  def game_gather_data!
    survey if may_survey?
    self.state["game_survey_count"] += 1
    if self.state["game_survey_count"] > 6 then
      reset!
      take_action!
      return
    end
    save!

    # sample time should be 10-15 minutes from now
    time = Time.now + (10 + rand(5)).minutes

    self.delay(run_at: time).game_gather_data!

    return do_message!(build_survey_message, time)
  end

  def incoming_message message
    state = self.aasm_state.to_s
    if state =~ /^waiting_asked/ then
      # We asked if they wanted to start a game
      if message =~ /yes/i then
        game_begin!
      elsif message =~ /no/i then
        game_delay!
      end
    elsif state =~ /^waiting_number/ then
      game_send_result!(message)
    else
      logger.warn("Got unexpected participant message #{message} from participant #{participant.id} in game state #{self.inspect}")
    end
  end

  def take_action!
    current = self.aasm_state.to_s
    if current =~ /^waiting/ then
      # Don't start any new actions if waiting for response
      return false
    end

    day = get_day
    unless day
      Rails.logger.info("Participant has no more available days")
      return false
    end

    today_game_time = self.time_for_game self.participant

    message_text, scheduled_at = 
      if current == "none" and
        Time.now > today_game_time and
        not self.state["game_completed_dayid"].include? day.id then
        # TODO: This should trigger on a postback from Qualtrics,
        # when we know they finished a default survey
        # ... otherwise, this gets called too often after a timeout
        self.game_could_start!
      else
        # The default question
        [ "Please take this survey now (sent at {{sent_time}}): {{redirect_link}}",
          day.random_time_for_next_question ]
      end

    self.save!
    return self.do_message! message_text, scheduled_at
  end
end
