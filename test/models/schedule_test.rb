# -*- encoding : utf-8 -*-
require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  def setup
    @ppt = participants(:ppt1)
    @survey = @ppt.survey
    super
  end


  test "build for ppt not nil" do
    schedule = Schedule.build_for_participant @ppt
    refute_nil schedule
  end

  test "build for ppt returns the correct day count" do
    schedule = Schedule.build_for_participant @ppt
    assert_equal @survey.sampled_days, schedule.days.length
  end

  test "build for ppt starts with tomorrow and returns correct days" do
    schedule = Schedule.build_for_participant @ppt
    today = Date.today
    @survey.sampled_days.times do |day_count|
      expectation = today + day_count + 1
      assert_equal expectation, schedule.days[day_count].date
    end
  end
end