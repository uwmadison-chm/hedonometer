require 'test_helper'

class GameSurveyTest < ActiveSupport::TestCase
  def setup
    @survey = surveys(:game)
    @ppt = participants(:ppt3)
  end

  test "schedule survey question works" do
    q = @survey.schedule_survey_question_on_participant! @ppt
    refute_nil q
  end
end

