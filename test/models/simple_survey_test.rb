require 'test_helper'

class SimpleSurveyTest < ActiveSupport::TestCase
  def setup
    @ppt = participants(:ppt1)
    @survey = surveys(:test)
  end

  test "getting new question" do
    p = participants(:ppt1)
    sq = p.survey.choose_question p
    unused = p.state[:question_chooser_state][:unused_ids]
    refute_nil unused
    assert_equal (p.survey.survey_questions.count - 1), unused.length
    refute_includes p.state[:question_chooser_state][:unused_ids], sq.id
  end

  test "current or new question basically works" do
    q = @survey.current_question_or_new @ppt
    refute_nil q
  end

  test "schedule participant works" do
    q = @survey.schedule_participant! @ppt
    refute_nil q
  end

  test "schedule and save works" do
    q = @survey.schedule_participant! @ppt
    refute q.new_record?
  end

  test "current or new doesn't find delivered questions" do
    sday = @ppt.schedule_days.first
    sq = sday.scheduled_messages.create!(
      survey_question: survey_questions(:test_what), scheduled_at: Time.now, aasm_state: 'delivered')
    refute_equal sq, @survey.current_question_or_new(@ppt)
  end
end
