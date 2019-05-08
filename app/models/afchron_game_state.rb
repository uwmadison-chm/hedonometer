class AfchronGameState < ParticipantState
  def initialize
    super
    self.game_initialized = true
    self.game_count = 0
    self.game_time = {}
    self.game_measure_with_link = true # TODO - should be survey-dependent
    self.game_result_pool = generate_game_result_pool
    self.game_result = []
    self.game_balance = 0
    # Current schedule day id
    self.game_current_day = nil
    # Hash of schedule_day ids that contains if they won or lost
    self.game_completed = {}
  end

  def generate_game_result_pool
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

  aasm do
    state :none, initial: true
    state :asked_to_play
    state :waiting_asked
    state :waiting_number
    state :after_game_surveying
    state :waiting_for_survey

    event :asked_to_play do
      transitions from: :none, to: :asked_to_play
    end

    event :play do
      transitions from: :asked_to_play, to: :playing
    end
  end
end
