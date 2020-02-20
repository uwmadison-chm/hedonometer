class AfchronGameState < ParticipantState
  belongs_to :participant
  aasm column: 'aasm_state' do
    state :none, initial: true
    state :waiting_asked
    state :waiting_number
    state :game_surveying

    event :ask_to_play do
      transitions from: :none, to: :waiting_asked
    end

    event :play do
      transitions from: :waiting_asked, to: :waiting_number
    end

    event :game_survey do
      transitions from: :waiting_number, to: :game_surveying
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

  def waiting?
    game_surveying? or waiting_asked? or waiting_number?
  end

  def set_defaults!
    self.state["game_time"] = nil
    self.state["result_pool"] = generate_result_pool
    self.state["game_balance"] = 0
    self.state["game_completed_results"] = [] # List of results
    self.state["game_completed_dayid"] = [] # List of day ids
    self.state["game_completed_time"] = [] # List of completed times
    self.state["surveys_for_day"] = {} # Hash of surveys by day, a list of times
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
      participant.schedule_days.potential_run_targets.each do |d|
        if d.waiting?
          d.run!
          day = d
          break
        end
      end
    end
    day
  end

  def time_for_game
    day = get_day
    # Does participant have a game start time for this day?
    # If not, decide when game prompt should start today
    time = get_game_time
    if time.nil? then
      day_length = participant.survey.day_length
      # pick a time in first 70% of time range 
      section = day_length * 0.7
      jitter = rand
      random_point = section * jitter
      time = day.starts_at + random_point
      logger.info("Game time chosen: #{time} using day length #{day_length} day starts at #{day.starts_at} + (#{section} * #{jitter} = #{random_point})")
      self.state["game_time"] = time
    end
    time
  end

  def range_from_timepoint point
    plusminus = participant.survey.configuration['sample_minutes_plusminus']
    return (point - plusminus.minutes)..(point + plusminus.minutes)
  end

  def parse_times array
    array.map! do |x|
      if x.kind_of? Time then
        x
      else
        Time.parse x.to_s
      end
    end
  end

  def surveys_for_day day
    self.state["surveys_for_day"] ||= {}
    parse_times(self.state["surveys_for_day"][day.id.to_s] ||= [])
  end

  def set_surveys_for_day day, value
    self.state["surveys_for_day"] ||= {}
    self.state["surveys_for_day"][day.id.to_s] = value
  end

  def game_surveys_for_day day
    self.state["game_surveys_for_day"] ||= {}
    parse_times(self.state["game_surveys_for_day"][day.id.to_s] ||= [])
  end

  def set_game_surveys_for_day day, value
    self.state["game_surveys_for_day"] ||= {}
    self.state["game_surveys_for_day"][day.id.to_s] = value
  end


  def time_for_survey day
    day_start = day.starts_at
    day_end = day.ends_at
    samples_per_day = participant.survey.configuration['samples_per_day']
    plusminus = participant.survey.configuration['sample_minutes_plusminus']
    sent_surveys = surveys_for_day day
    if sent_surveys.count == 0 then
      # Start of day! Pick a time within the first +/- minutes.
      point = day_start + plusminus
      time = rand(day_start..point)
    else
      # Are we done for today?
      if sent_surveys.count >= samples_per_day
        Rails.logger.info "Done sampling #{sent_surveys} times for day #{day.id}"
        return false
      elsif Time.now > day_end then
        Rails.logger.info "Past day_end #{day_end} on day #{day.id}"
        return false
      end

      if sent_surveys.count + 1 == samples_per_day
        # Last one goes near the end somewhere
        range = (day_end - plusminus.minutes)..day_end
      else
        # Otherwise, subdivide remaining time
        last_time = sent_surveys.last
        sent_game_surveys = game_surveys_for_day day
        if sent_game_surveys.count > 0 then
          if sent_game_surveys.last > last_time then
            last_time = sent_game_surveys.last
          end
        end
        remaining_surveys = samples_per_day - sent_surveys.count
        mean_length = (day_end - last_time) / remaining_surveys
        point = last_time + mean_length 
        range = range_from_timepoint point
      end
      time = rand range
    end

    # Store that we are surveying at this time
    sent_surveys.push time
    return time
  end

  def link_survey!
    day = get_day
    if not day then
      Rails.logger.info "No days remaining for participant #{participant.id}"
      return false
    end
    time = time_for_survey day
    self.save!
    unless time
      # No time on this day or we're done, start over on next day
      day.finish!
      return link_survey!
    end
    message = do_message! "Please take this survey now (sent at {{sent_time}}): {{redirect_link}}", time
    message.destination_url = participant.survey.url
    message.save!
    return message
  end

  def game_could_start!
    # Ask the participant if they want to play
    ask_to_play!
    self.delay(run_at: Time.now + 30.minutes).do_timeout!
    return do_message! "Do you have time to play a game? (Reply 'yes' if so, no reply is needed if not)",
      Time.now + 15.minutes
  end

  def do_timeout!
    if waiting_asked? or waiting_number? then
      # Just retrigger later today, they didn't respond
      timeout
      self.state["game_time"] = Time.now + 30.minutes
      save!
      take_action!
    elsif game_surveying? then
      # This is not actually called by production code, but is useful for the simulator
      game_gather_data!
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
    if message =~ /(^h$)|high|(^l$)|low/i then
      guessed_high = message =~ /(^h$)|high/i
    else
      return do_message!("You need to pick 'high' or 'low'", Time.now)
    end

    # Participant picked high or low... tell them what they won, Jim!

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
    self.state["game_completed_dayid"].push get_day.id.to_s
    self.state["game_completed_time"].push Time.now
    self.state["game_balance"] += winner ? 10 : -5

    save!

    # We go into gather data mode
    game_gather_data!

    message =
      "The number was #{number}. " +
      (winner ? "You guessed right! $10 has been added to your account." : "You guessed wrong! $5 has been removed from your account.")
    return do_message!(message, Time.now, self.participant.survey.url_game_survey)
  end

  def game_gather_data!
    game_survey if may_game_survey?
    sent_surveys = game_surveys_for_day get_day
    if sent_surveys.count >= 6 then
      reset!
      return link_survey!
    end

    if sent_surveys.count == 0 then
      time = Time.now + (5 + rand(5)).minutes
    else
      time = sent_surveys.last + (10 + rand(5)).minutes
    end
    
    sent_surveys.push time
    save!

    return do_message!("Please take this short survey now (sent at {{sent_time}}): {{redirect_link}}", time)
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
    day = get_day
    unless day
      Rails.logger.info("Participant has no more available days")
      return false
    end

    if day.scheduled_messages.pending.count > 0 then 
      Rails.logger.debug("Not scheduling an action, already pending messages")
      return false
    end

    today_game_time = self.time_for_game

    if game_surveying? then
      # Game gathering should trigger after text messages get sent
      game_gather_data!
    elsif waiting? then
      # Other waiting things trigger via incoming text message
      nil
    elsif none? and
      Time.now > today_game_time and
      not self.state["game_completed_dayid"].include? day.id.to_s then
      # TODO: This should trigger on a postback from Qualtrics,
      # when we know they finished a default survey...
      # However, if we do trigger from Qualtrics, then we need another
      # timeout to catch the ppt opening the link but not finishing. Neat.
      Rails.logger.info("Starting game for day #{day.id}, participant state completed games is #{self.state["game_completed_dayid"].inspect}")
      game_could_start!
    else
      link_survey!
    end
  end
end
