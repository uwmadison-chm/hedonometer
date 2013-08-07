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
        tp = TimeRange.new(t1, t2)
        Day.new(date, [tp])
      }
      self.new(days)
    end
  end

  class Day
    attr_accessor :date
    attr_accessor :time_ranges
    def initialize(date, time_ranges)
      @date = date
      @time_ranges = time_ranges
    end

    def time_range_strings
      time_ranges.join " - "
    end

  end

  class TimeRange
    attr_accessor :start_at
    attr_accessor :end_at
    FORMAT_STRING = "%l:%M %p"

    def initialize(start_at, end_at)
      @start_at = start_at
      @end_at = end_at
    end

    def to_s
      # 9:00 AM - 5:15PM
      [start_at, end_at].map {|t| t.localtime.strftime(FORMAT_STRING)}.join(" - ")
    end
  end
end