require 'test_helper'

class LinkSurveyTest < ActiveSupport::TestCase
  def setup
    @survey = surveys(:link)
    @ppt = participants(:ppt4)
    @day = schedule_days(:ppt4_test_day_1)
  end

  test "scheduling participant sets message text but not survey question" do
    q = @survey.schedule_participant! @ppt
    assert_includes q.message_text, "sent at {{sent_time}}"
    assert_nil q.survey_question
  end

  test "replaced text contains survey link, which is to this site" do
    q = @survey.schedule_participant! @ppt
    refute_nil q
    assert_includes q.message_text, "{{redirect_link}}"
    assert_includes q.destination_url, "qualtrics.com"
  end

  test "scheduling participant with no messages sets message time within plus/minus * 2" do
    q = @survey.schedule_participant! @ppt
    duration = q.scheduled_at - Time.now
    assert_operator duration, :<=, (@survey.sample_minutes_plusminus * 2).minutes
  end

  test "scheduling participant with 1 completed message schedules it in the correct range" do
    q1 = @survey.schedule_participant! @ppt

    q1.delivered_at = Time.now
    q1.mark_delivered
    q1.save!

    q2 = @survey.schedule_participant! @ppt

    duration = q2.scheduled_at - q1.scheduled_at

    assert_operator duration, :>=, (@survey.mean_minutes_between_samples + @survey.sample_minutes_plusminus).minutes
  end
end


