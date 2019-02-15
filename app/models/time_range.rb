# -*- encoding : utf-8 -*-
class TimeRange
  FORMAT_STRING = "%-l:%M %P"
  attr_accessor :first
  attr_accessor :end

  def initialize(first_at, end_at)
    # These can come in as ActiveSupport::TimeWithZone or DateTime or... who knows
    # TODO: we don't force time zone to be correct on DateTime yet
    @first = first_at
    @end = end_at
  end

  def last
    @end
  end

  def to_s
    # 9:00 AM - 5:15 PM
    [@first, @end].map {|t| t.in_time_zone.strftime(FORMAT_STRING)}.join(" - ")
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
    sd, ed = range_string.split("-").map {|time_str| Time.zone.parse("#{date} #{time_str}")}
    # Handle ranges like 5:00 PM - 2:00 AM
    ed += 1.day if ed < sd
    self.new(sd, ed)
  end
end
