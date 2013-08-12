# -*- encoding : utf-8 -*-
require 'time_range'
class ScheduleDay < ActiveRecord::Base
  belongs_to :participant
  validates :participant, presence: true
  validates :date, presence: true, uniqueness: {scope: :participant_id}

  serialize :time_ranges

  # TODO: Add validation for time_ranges_string

  def time_ranges_string
    self.time_ranges.join(", ")
  end

  def time_ranges_string=(str)
    #TODO move this to a before_save handler
    if str == ""
      self.time_ranges = []
    end
    self.time_ranges = str.split(", ").map {|range_str| TimeRange.from_date_and_string(self.date, range_str)}
  end
end
