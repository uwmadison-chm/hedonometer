require 'test_helper'

class LinkSurveyTest < ActiveSupport::TestCase
  def setup
    @survey = surveys(:link)
    @ppt = participants(:ppt3)
  end

  test "schedule survey question works" do
    # TODO
    q = @survey.schedule_participant! @ppt
    refute_nil q
  end

  test "text contains survey link" do
    # TODO
  end
end


