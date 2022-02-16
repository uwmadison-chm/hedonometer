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

  test "replaced text contains survey link, which has a destination url" do
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

  test "scheduling participant with 1 completed message schedules next in the correct range" do
    q1 = @survey.schedule_participant! @ppt

    q1.delivered_at = q1.scheduled_at
    q1.mark_delivered
    q1.save!

    q2 = @survey.schedule_participant! @ppt

    duration = q2.scheduled_at - q1.scheduled_at
    multiplier = 3

    assert_operator duration, :>=, (@survey.mean_minutes_between_samples - @survey.sample_minutes_plusminus * multiplier).minutes
    assert_operator duration, :<=, (@survey.mean_minutes_between_samples + @survey.sample_minutes_plusminus * multiplier).minutes
  end

  test "scheduling participant with 2 completed messages schedules next in the correct range" do
    q1 = @survey.schedule_participant! @ppt
    q1.delivered_at = q1.scheduled_at
    q1.mark_delivered
    q1.save!

    q2 = @survey.schedule_participant! @ppt
    q2.delivered_at = q2.scheduled_at
    q2.mark_delivered
    q2.save!

    q3 = @survey.schedule_participant! @ppt
    q3.delivered_at = q3.scheduled_at
    q3.mark_delivered
    q3.save!

    duration = q3.scheduled_at - q2.scheduled_at
    multiplier = 2

    assert_operator duration, :>=, (@survey.mean_minutes_between_samples - @survey.sample_minutes_plusminus * multiplier).minutes
    assert_operator duration, :<=, (@survey.mean_minutes_between_samples + @survey.sample_minutes_plusminus * multiplier).minutes
  end
end


