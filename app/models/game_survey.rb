class GameSurvey < Survey
  def self.model_name
    Survey.model_name
  end

  def prepare_games participant
    s = participant.state
    return if s['game_initialized']
    s['game_initialized'] = true
    s['game_count'] = 0
    s['game_time'] = {}
    s['game_measure_with_link'] = true
    # TODO: Make pseudorandom where they can't lose 3 in a row
    s['game_result_pool'] = [true, false, true, true, false, true, false, true, false, false]
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
      # TODO
      time = Time.now + 30.minutes
      participant.state['game_time'][day.id] = time
    end
    time
  end

  def game_timed_out! participant
    case participant.state['game']
    when 'waiting_asked', 'waiting_number' then
      # Just retrigger later today, they didn't respond
      participant.state['game'] = nil
      participant.state['game_time'][day.id] = Time.now + 30.minutes
      schedule_participant! participant
    end
  end

  def game_could_start! participant
    # Ask the participant if they want to play
    participant.state['game'] = 'waiting_asked'
    # TODO: Add a delayed job which will mark the participant out of game mode if they have not replied
    return "Do you have time to play a game? (Reply 'yes' if so, or just ignore us if not)", Time.now
  end

  def game_begin! participant
    # Participant said yes, begin the game
    participant.state['game'] = 'waiting_number'
    participant.state['game_count'] += 1
    # TODO: Add a delayed job which will mark the participant out of game mode if they have not replied
    return "I picked a number...", Time.now # TODO
  end

  def game_send_result! participant
    # Participant picked a number... tell them what they won, Jim!
    participant.state['game'] = 'gather_data'
    participant.state['game_survey_count'] = 0

    # store if they won or not
    winner = participant.state['game_result_pool'].shift
    s['game_result'].push winner
    # also store this day as completed
    s['game_completed'][s['game_current_day']] = winner
    s['game_balance'] += winner ? 10 : -5

    message = winner ? "Correct! You won $10!" : "Incorrect! You lose $5."
    return "#{message} Your balance is #{s['game_balance']}", Time.now
  end

  def game_gather_data! participant
    participant.state['game_survey_count'] += 1
    if participant.state['game_survey_count'] >= 8 then
      participant.state['game'] = nil
    end
    # TODO: random time should be 10-15 minutes from now
    time = day.random_time_for_next_question
    # TODO: Add a delay to timeout and re-ask
    if s['game_measure_with_link'] then
      return "Please take this short survey now (sent at {{sent_time}}): {{redirect_link}}", time
    else
      return "How do you feel on a scale of 1 to 10?", time
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
        # when we know they finished a long survey
        game_could_start! participant
      else
        case state_game
        when 'begin'
          s['game_current_day'] = day.id
          game_begin! participant
        when 'send_result'
          game_send_result! participant
        when 'gather_data'
          game_gather_data! participant
        else
          # The default question
          ["Please take this survey now (sent at {{sent_time}}): {{redirect_link}}", day.random_time_for_next_question]
        end
      end

    participant.save!
    message = day.scheduled_messages.build(message_text: message_text, scheduled_at: scheduled_at)
    message.save!
    message
  end
end
