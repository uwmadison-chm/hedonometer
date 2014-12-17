# -*- encoding : utf-8 -*-
require 'test_helper'

class SurveyTest < ActiveSupport::TestCase
  def setup
  end

  def sample_survey_params
    {
      creator: admins(:nate),
      name: "test1",
      samples_per_day: 1,
      mean_minutes_between_samples: 15,
      sample_minutes_plusminus: 5,
      active: false
    }
  end

  test "create a simple survey" do
    s = Survey.create sample_survey_params
    assert s.valid?
    refute s.new_record?
  end

  test "validations are firing" do
    p = sample_survey_params
    p.delete(:creator)
    s = Survey.create p
    refute s.valid?
  end

  test "creator gets assigned as an admin" do
    s = Survey.create sample_survey_params
    assert_equal s.admins.first, admins(:nate)
    assert admins(:nate).can_modify_survey?(s)
  end

  test "phone number serialization" do
    assert_kind_of PhoneNumber, surveys(:test).phone_number
  end
end
