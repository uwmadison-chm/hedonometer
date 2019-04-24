class GameSurvey < Survey
  def self.model_name
    Survey.model_name
  end

  def url
    configuration['url']
  end

  def url= x
    configuration['url'] = x
  end

  def url_game_survey
    configuration['url_game_survey']
  end

  def url_game_survey= x
    configuration['url_game_survey'] = x
  end

  def url_for_participant participant
    # Different survey urls depending on participant state
    s = participant.state
    if s['game'] == 'gather_data' then
      url_game_survey
    else
      url
    end
  end

  def game_result_pool
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

  def prepare_games participant
    s = participant.state
    return if s['game_initialized']
    s['game_initialized'] = true
    s['game_count'] = 0
    s['game_time'] = {}
    s['game_measure_with_link'] = true
    s['game_result_pool'] = game_result_pool
    s['game_result'] = []
    s['game_balance'] = 0
    # Current schedule day id
    s['game_current_day'] = nil
    # Hash of schedule_day ids that contains if they won or lost
    s['game_completed'] = {}
  end

  def game_time_for participant, day
    # Does participant have a game start time for this day?
    # If not, decide when game prompt should start today
    time = participant.state['game_time'][day.id.to_s]
    if time.nil? then
      # pick a time in first 80% of time range 
      time = day.starts_at + (day.day_length * 0.8 * rand)
      participant.state['game_time'][day.id] = time
    end
    time
  end

  def game_timed_out! participant
    case participant.state['game']
    when 'waiting_asked', 'waiting_number' then
      # Just retrigger later today, they didn't respond
      participant.state['game'] = nil
      day_id = participant.state['game_current_day']
      participant.state['game_time'][day_id] = Time.now + 30.minutes
      schedule_participant! participant
    end
  end

  def game_could_start! participant
    # Ask the participant if they want to play
    participant.state['game'] = 'waiting_asked'
    self.delay(run_at: Time.now + 10.minutes).game_timed_out! participant
    return "Do you have time to play a game? (Reply 'yes' if so, no reply is needed if not)", Time.now
  end

  def game_begin! participant
    # Participant said yes, begin the game
    day_id = participant.state['game_current_day']
    participant.state['game_current_day'] = day_id
    participant.state['game'] = 'waiting_number'
    participant.state['game_count'] += 1
    self.delay(run_at: Time.now + 10.minutes).game_timed_out! participant
    message = "We generated a number between 1 and 9. Guess if it's lower or higher than 5. Reply 'high' or 'low'."
    return message, Time.now
  end

  def game_send_result! day, participant, guessed_high
    # Participant picked high or low... tell them what they won, Jim!
    s = participant.state
    s['game_survey_count'] = 0

    # store if they won or not
    winner = participant.state['game_result_pool'].shift
    s['game_result'].push winner
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
    s['game_completed'][s['game_current_day']] = winner
    s['game_balance'] += winner ? 10 : -5

    # We go into gather data mode
    game_gather_data! participant

    message =
      "The number was #{number}" +
      (winner ? "You guessed right! $10 has been added to your account." : "You guessed wrong! $5 has been removed from your account.")
    return message, Time.now
  end

  def game_gather_data! participant
    s = participant.state
    s['game'] = 'gather_data'
    s['game_survey_count'] += 1
    if s['game_survey_count'] >= 8 then
      s['game'] = nil
    end
    # sample time should be 10-15 minutes from now
    time = Time.now + (10 + rand(5)).minutes

    # Timeout after another chunk of minutes if no response, prompt again
    timeout = time + (10 + rand(5)).minutes
    self.delay(run_at: timeout).game_gather_data_again! s['game_survey_count'], participant.id
    if s['game_measure_with_link'] then
      return "Please take this short survey now (sent at {{sent_time}}): {{redirect_link}}", time
    else
      return "How do you feel on a scale of 1 to 10?", time
    end
  end

  def game_gather_data_again! count, participant_id
    # re-ask if they didn't respond last time
    ppt = Participant.find(participant_id)
    if ppt.state['game_survey_count'] == count then
      self.game_gather_data! ppt
    end
  end

  def schedule_participant! participant
    participant.requests_new_schedule = false
    day = participant.schedule_days.advance_to_day_with_time_for_message!
    unless day
      logger.info("Participant has no more available days")
      return false
    end
    
    prepare_games participant
    today_game_time = game_time_for(participant, day)
    state_game = participant.state['game'] 

    if state_game =~ /^waiting/ then
      # Don't start any new actions if waiting for response
      return false
    end

    message_text, scheduled_at = 
      if state_game.nil? and
        Time.now > today_game_time and
        not participant.state['game_completed'].include? day then
        # TODO: This should trigger on a postback from Qualtrics,
        # when we know they finished a default survey
        # ... otherwise, this gets called too often after a timeout
        game_could_start! participant
      else
        case state_game
        when 'send_result'
        when 'gather_data'
          game_gather_data! participant
        else
          # The default question
          [ "Please take this survey now (sent at {{sent_time}}): {{redirect_link}}",
            day.random_time_for_next_question ]
        end
      end

    participant.save!
    return do_message day, message_text, scheduled_at
  end

  def do_message day, message_text, scheduled_at
    message = day.scheduled_messages.build(message_text: message_text, scheduled_at: scheduled_at)
    message.save!
    logger.debug("Scheduled #{message.inspect}")
    ParticipantTexter.delay(run_at: message.scheduled_at).deliver_scheduled_message!(message.id)
    return message
  end

  def participant_message participant, message
    day = participant.schedule_days.running_day
    s = participant.state
    game_state = s['game'] 
    if game_state =~ /^waiting_asked/ then
      # We asked if they wanted to start a game
      if message =~ /yes/i then
        do_message(day, *game_begin!(participant))
        participant.save!
      elsif message =~ /no/i then
        day_id = s['game_current_day']
        s['game_time'][day_id] = Time.now + 30.minutes
        participant.save!
      end
    elsif game_state =~ /^waiting_number/ then
      if message =~ /high|low/ then
        guessed_high = message =~ /high/
        do_message(day, *game_send_result!(day, participant, message, guessed_high))
        participant.save!
      else
        do_message(day, "You need to pick 'high' or 'low'", Time.now)
      end
    elsif game_state =~ /^gather_data/ then
      if message =~ /\d+/ then
        s['game_response'][day_id] ||= []
        s['game_response'][day_id].push message
      end
    else
      logger.debug("Got unexpected participant message #{message} from participant #{participant.id} in game state #{game_state}")
    end
  end
end
