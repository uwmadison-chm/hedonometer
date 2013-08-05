class Schedule

  attr_accessor :days

  def initialize(days)
    @days = days
  end

  class << self
    def build_for_participant(participant)
      today = Time.zone.now.to_date
      survey = participant.survey
      days = survey.sampled_days.times.map {|day_count|
        date = today + (day_count + 1)
        t1 = date + 9.hours
        t2 = t1 + survey.day_length_minutes.minutes
        tp = TimePeriod.new(t1, t2)
        Day.new(date, [tp])
      }
      self.new(days)
    end
  end

  class Day
    attr_accessor :date
    attr_accessor :time_periods

    def initialize(date, time_periods)
      @date = date
      @time_periods = time_periods
    end
  end

  class TimePeriod
    attr_accessor :start_at
    attr_accessor :end_at

    def initialize(start_at, end_at)
      @start_at = start_at
      @end_at = end_at
    end
  end
end