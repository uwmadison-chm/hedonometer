# -*- encoding : utf-8 -*-
require 'test_helper'

class TimeRangeTest < ActiveSupport::TestCase
  test "computes day length in minutes" do
    mins = 10
    t1 = Time.now
    t2 = t1 + mins.minutes
    tr = TimeRange.new(t1, t2)
    assert_equal mins, tr.length_minutes
  end

  test "normal time range parsing" do
    d = Time.now.utc.to_date
    tr = TimeRange.from_date_and_string(d, "9:00 AM - 10:00 AM")
    assert_equal (d + 9.hours), tr.first
    assert_equal (d + 10.hours), tr.end
  end

  test "cross-day parsing" do
    d = Time.now.utc.to_date

    tr = TimeRange.from_date_and_string(d, "11:00 PM - 1:00 AM")
    assert_equal (d + 23.hours), tr.first
    assert_equal (d + 25.hours), tr.end
    assert_equal 120, tr.length_minutes
  end
end
