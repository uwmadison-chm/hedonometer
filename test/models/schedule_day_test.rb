require 'test_helper'

class ScheduleDayTest < ActiveSupport::TestCase

  def setup
    @sd = schedule_days(:test_day_1)
    super
  end

  def setup_sample_time_ranges
    t1 = Time.zone.parse("2013-05-04 10:00 AM")
    @sample_time_ranges ||= [
      TimeRange.new(t1, t1+1.hour),
      TimeRange.new(t1+2.hours, t1+3.hours),
      TimeRange.new(t1+(3.5).hours, t1+(3.75).hours)]
    @sd.time_ranges = @sample_time_ranges
    @start = @sample_time_ranges[0].first
  end

  test "valid time without bump" do
    setup_sample_time_ranges
    t = @sd.valid_time_after_day_start(30.minutes)
    assert_equal @start+30.minutes, t
  end

  test "valid time with bumps" do
    setup_sample_time_ranges
    t = @sd.valid_time_after_day_start(61.minutes)
    assert_equal @sample_time_ranges[1].first + 1.minute, t
    t = @sd.valid_time_after_day_start(121.minutes)
    assert_equal @sample_time_ranges[2].first + 1.minute, t
  end

  test "not enough time" do
    setup_sample_time_ranges
    assert_nil @sd.valid_time_after_day_start(3.hours)
  end

  test "minimum time to next question" do
    survey = @sd.participant.survey
    min_time = (survey.mean_minutes_between_samples - survey.sample_minutes_plusminus).minutes
    assert_equal min_time, @sd.minimum_time_to_next_question
    q = @sd.scheduled_questions.create(
      survey_question: survey_questions(:test_what),
      scheduled_at: @sd.time_ranges.first.first + 10.minutes,
      delivered_at: @sd.time_ranges.first.first + 10.minutes
      )
    min_time = (2*survey.mean_minutes_between_samples - survey.sample_minutes_plusminus).minutes
    assert_equal min_time, @sd.minimum_time_to_next_question
  end

  test "maximum time to next question" do
    survey = @sd.participant.survey
    min_time = (survey.mean_minutes_between_samples + survey.sample_minutes_plusminus).minutes
    assert_equal min_time, @sd.maximum_time_to_next_question
    q = @sd.scheduled_questions.create(
      survey_question: survey_questions(:test_what),
      scheduled_at: @sd.time_ranges.first.first + 10.minutes,
      delivered_at: @sd.time_ranges.first.first + 10.minutes
      )
    min_time = (2*survey.mean_minutes_between_samples + survey.sample_minutes_plusminus).minutes
    assert_equal min_time, @sd.maximum_time_to_next_question
  end

  test "first potentials" do
    ppt = participants(:ppt1)
    sd = ppt.schedule_days.first_potential
    assert_equal schedule_days(:test_day_1), sd
    sd.run
    sd.save
    sd = ppt.schedule_days.first_potential
    assert_equal schedule_days(:test_day_1), sd
    sd.finish
    sd.save
    sd = ppt.schedule_days.first_potential
    assert_equal schedule_days(:test_day_2), sd
    sd.skip
    sd.save
    assert_nil ppt.schedule_days.first_potential
  end
end
