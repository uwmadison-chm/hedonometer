require 'test_helper'

class ScheduleDayTest < ActiveSupport::TestCase

  def setup
    @sd = ScheduleDay.new
    @sd.time_ranges = sample_time_ranges
    @start = sample_time_ranges[0].first
    super
  end

  def sample_time_ranges
    t1 = Time.zone.parse("2013-05-04 10:00 AM")
    @sample_time_ranges ||= [
      TimeRange.new(t1, t1+1.hour),
      TimeRange.new(t1+2.hours, t1+3.hours),
      TimeRange.new(t1+(3.5).hours, t1+(3.75).hours)]
  end

  test "time bumping" do
    t = @sd.valid_future_time_from(@start, 30.minutes)
    assert_equal (@start + 30.minutes), t
    t = @sd.valid_future_time_from(@start, 90.minutes)
    assert_equal (@start + 150.minutes), t
  end

  test "find time range inside" do
    tr = @sd.time_range_for(@start)
    assert_equal @sample_time_ranges[0], tr
    tr = @sd.time_range_for(@start + 150.minutes)
    assert_equal @sample_time_ranges[1], tr
  end

  test "find time range with bumping" do
    tr = @sd.time_range_for(@start + 61.minutes)
    assert_equal @sample_time_ranges[1], tr
    tr = @sd.time_range_for(@start + 4.hours)
    assert_nil tr
  end

  test "truncate time ranges from start" do
    test_start = @start + (2.5).hours
    ranges = @sd.truncated_time_ranges_starting_at(test_start)
    assert_equal 2, ranges.length
    assert_equal test_start, ranges[0].first
  end

  test "truncate time ranges between ranges" do
    test_start = @start + (1.5).hours
    ranges = @sd.truncated_time_ranges_starting_at(test_start)
    assert_equal 2, ranges.length
    assert_equal (@start + 2.hours), ranges[0].first
  end

  test "truncate returns nothing if too late" do
    test_start = @start + 4.hours
    ranges = @sd.truncated_time_ranges_starting_at(test_start)
    assert_empty ranges
  end
end
