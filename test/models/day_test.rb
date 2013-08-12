# -*- encoding : utf-8 -*-
require 'test_helper'

class DayTest < ActiveSupport::TestCase
  test "compute length in minutes" do
    t1 = Time.now
    tr1 = TimeRange.new(t1, t1+10.minutes)
    tr2 = TimeRange.new(t1+30.minutes, t1+40.minutes)
    d = Day.new(t1.to_date, [tr1, tr2])
    assert_equal 20, d.length_minutes
  end
end
