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
    self.state["surveys_sent_by_day"] = {} # Hash of surveys by day, a list of times
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
      # pick a time in first 60% of time range 
      time = day.starts_at + (day.day_length * 0.6 * rand)
      self.state["game_time"] = time
    end
    time
  end

  def range_from_timepoint point
    plusminus = participant.survey.configuration['sample_minutes_plusminus']
    return (point - plusminus.minutes)..(point + plusminus.minutes)
  end

  def time_for_survey day
    day_start = day.starts_at
    day_end = day.ends_at
    samples_per_day = participant.survey.configuration['samples_per_day']
    sent_surveys = self.state["surveys_sent_by_day"][day.id.to_s] ||= []
    if sent_surveys.count == 0 then
      # Start of day! Pick a time within the first mean.
      # Note that this is not exactly what we want
      mean_length = (day_end - day_start) / samples_per_day
      point = day_start + mean_length
      time = rand(day_start..point)
    else
      if sent_surveys.count >= samples_per_day || Time.now > day_end then
        # We're done for today
        return false
      end
      # Otherwise, subdivide remaining time
      last_time = sent_surveys.last
      remaining_surveys = samples_per_day - sent_surveys.count
      mean_length = (day_end - last_time) / remaining_surveys
      point = last_time + mean_length 
      range = range_from_timepoint point
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
    return do_message! "Please take this survey now (sent at {{sent_time}}): {{redirect_link}}", time
  end

  def game_could_start!
    # Ask the participant if they want to play
    ask_to_play!
    self.delay(run_at: Time.now + 30.minutes).do_timeout!
    return self.do_message! "Do you have time to play a game? (Reply 'yes' if so, no reply is needed if not)",
      Time.now + 15.minutes
  end

  def do_timeout!
    case aasm_state.to_s
    when 'waiting_asked', 'waiting_number' then
      # Just retrigger later today, they didn't respond
      timeout
      self.state["game_time"] = Time.now + 30.minutes
      save!
      take_action!
    when 'waiting_survey' then
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
    if message =~ /high|low/i then
      guessed_high = message =~ /high/i
    else
      return do_message!("You need to pick 'high' or 'low'", Time.now)
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
    self.state["game_completed_dayid"].push get_day.id.to_s
    self.state["game_completed_time"].push Time.now
    self.state["game_balance"] += winner ? 10 : -5

    # We go into gather data mode
    game_gather_data!

    message =
      "The number was #{number}. " +
      (winner ? "You guessed right! $10 has been added to your account." : "You guessed wrong! $5 has been removed from your account.")
    return do_message!(message, Time.now)
  end

  def game_gather_data!
    survey if may_survey?
    if self.state["game_survey_count"] >= 6 then
      reset!
      return link_survey!
    end
    self.state["game_survey_count"] += 1
    save!

    # sample time should be 10-15 minutes from now
    time = Time.now + (10 + rand(5)).minutes

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

    today_game_time = self.time_for_game

    # TODO: what's the right way to check AASM state?
    if self.waiting_for_survey? then
      game_gather_data!
    elsif self.none? and
      Time.now > today_game_time and
      not self.state["game_completed_dayid"].include? day.id.to_s then
      # TODO: This should trigger on a postback from Qualtrics,
      # when we know they finished a default survey
      # ... otherwise, this gets called too often after a timeout
      # However, if we trigger from Qualtrics, then we need another
      # timeout to catch the ppt opening the link but not finishing
      game_could_start!
    else
      link_survey!
    end
  end
end
