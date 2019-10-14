# -*- encoding : utf-8 -*-
class TimeRange
  attr_accessor :first
  attr_accessor :end

  def initialize(first_at, end_at)
    # These can come in as ActiveSupport::TimeWithZone or DateTime or... who knows
    # They should always be stored in UTC
    @first = first_at.getutc
    @end = end_at.getutc
  end

  def last
    @end
  end

  def to_s
    # 9:00 AM - 5:15 PM
    to_s_local ActiveSupport::TimeZone['UTC']
  end

  def to_s_local timezone
    [@first, @end].map {|t| t.in_time_zone(timezone).strftime("%-l:%M %P")}.join(" - ")
  end

  def include?(t)
    # Oddly, Range#include? does not seem to work right
    @first <= t and @end >= t
  end

  def length_minutes
    duration/60
  end

  def duration
    result = @end - @first
    if result.is_a? Rational then
      # Return as ActiveSupport::Duration instead of just a rational fraction of days
      result = result.days
    end
    result
  end

  def self.from_date_and_string(date, range_string)
    sd, ed = range_string.split(/\s*-\s*/).map do |time_str|
      Time.find_zone("UTC").parse(time_str, date)
    end
    # Handle ranges like 5:00 PM - 2:00 AM
    ed += 1.day if ed < sd
    self.new(sd, ed)
  end
end
