# -*- encoding : utf-8 -*-
require 'time_range'
class ScheduleDay < ActiveRecord::Base
  belongs_to :participant
  validates :participant, presence: true
  validates :date, presence: true, uniqueness: {scope: :participant_id}

  serialize :time_ranges

  # TODO: Add validation for time_ranges_string

  def time_ranges_string
    self.time_ranges.map {|tr| tr.to_s}.join(", ")
  end

  def time_ranges_string=(str)
    #TODO move this to a before_save handler
    if str == ""
      self.time_ranges = []
    end
    self.time_ranges = str.split(", ").map {|range_str| TimeRange.from_date_and_string(self.date, range_str)}
  end

  def valid_future_time_from(start_at, future_seconds)
    ranges_to_search = self.truncated_time_ranges_starting_at(start_at)
    ranges_to_search.each do |range|
      if range.duration >= future_seconds
        return range.first + future_seconds
      end
      future_seconds -= range.duration
    end
  end

  def time_range_for(t)
    # Finds the time range in which t happens, or the possible one. Or nil.
    sorted = time_ranges.sort_by {|tr| tr.first}
    sorted.detect {|tr| tr.include? t} || sorted.detect {|tr| tr.first > t}
  end

  def truncated_time_ranges_starting_at(t)
    ranges = time_ranges.find_all {|tr| tr.end >= t}.map {|tr| tr.dup}
    return ranges if ranges.empty?
    new_start_time = [t, ranges[0].first].max
    ranges[0] = TimeRange.new(new_start_time, ranges[0].end)
    ranges
  end
end
