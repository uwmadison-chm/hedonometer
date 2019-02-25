require 'test_helper'

class LinkSurveyTest < ActiveSupport::TestCase
  def setup
    @survey = surveys(:link)
    @ppt = participants(:ppt4)
  end

  test "scheduling participant works" do
    q = @survey.schedule_participant! @ppt
    assert_includes q.message_text, "sent at {{sent_time}}"
    assert_nil q.survey_question
  end

  test "replaced text contains survey link" do
    q = @survey.schedule_participant! @ppt
    refute_nil q
    # TODO
  end
end


