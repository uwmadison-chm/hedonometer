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
end
