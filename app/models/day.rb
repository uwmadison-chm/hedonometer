# -*- encoding : utf-8 -*-
class Day
  attr_accessor :date
  attr_accessor :time_ranges
  def initialize(date, time_ranges)
    @date = date
    @time_ranges = time_ranges
  end

  def time_range_strings
    time_ranges.join ", "
  end

  def length_minutes
    @time_ranges.map {|tr| tr.length_minutes}.reduce(:+)
  end
end
