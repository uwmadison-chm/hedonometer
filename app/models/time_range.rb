# -*- encoding : utf-8 -*-
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

  def length_minutes
    (@end_at - @start_at)/60
  end

  def self.from_date_and_string(date, range_string)
    sd, ed = range_string.split("-").map {|time_str| Time.zone.parse("#{date} #{time_str}")}
    # Handle ranges like 5:00 PM - 2:00 AM
    ed += 1.day if ed < sd
    self.new(sd, ed)
  end
end
