# -*- encoding : utf-8 -*-
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
end