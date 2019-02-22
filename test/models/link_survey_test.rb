require 'test_helper'

class LinkSurveyTest < ActiveSupport::TestCase
  def setup
    @survey = surveys(:link)
    @ppt = participants(:ppt3)
  end

  test "schedule survey question works" do
    q = @survey.schedule_survey_question_on_participant! @ppt
    refute_nil q
  end
end


