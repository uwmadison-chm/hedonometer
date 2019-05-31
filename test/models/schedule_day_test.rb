require 'test_helper'

class ScheduleDayTest < ActiveSupport::TestCase

  def setup
    @sd = schedule_days(:test_day_1)
    super
  end

  def setup_sample_time_ranges
    t1 = Time.now.utc
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

  test "adjust_day_length_to with extra time" do
    setup_sample_time_ranges
    @sd.adjust_day_length_to(3.hours)
    assert_equal 3, @sd.time_ranges.length
    assert_equal 1.hour, @sd.time_ranges.last.duration
  end

  test "adjust_day_length_to with not enough time" do
    setup_sample_time_ranges
    @sd.adjust_day_length_to(90.minutes)
    assert_equal 2, @sd.time_ranges.length
    assert_equal 30.minutes, @sd.time_ranges.last.duration
  end

  test "adjust_day_length_to with exactly enough time" do
    setup_sample_time_ranges
    @sd.adjust_day_length_to(135.minutes)
    assert_equal 3, @sd.time_ranges.length
    assert_equal 15.minutes, @sd.time_ranges.last.duration
  end

  test "adjusting day length to survey" do
    survey = @sd.survey
    @sd.adjust_day_length_to(5.minutes)
    @sd.adjust_day_length_to_match_survey
    assert_equal survey.day_length, @sd.day_length
  end

  test "has time for another question with deliveries" do
    survey = @sd.survey
    t1 = Time.now
    t2 = t1 + survey.day_length
    @sd.time_ranges = [TimeRange.new(t1, t2)]
    @sd.survey.samples_per_day.times do |num|
      assert @sd.has_time_for_another_question?
      @sd.scheduled_messages.create(
        survey_question: survey_questions(:test_what),
        aasm_state: 'delivered',
        scheduled_at: t1)
    end
    refute @sd.has_time_for_another_question?
  end

  test "has time for another question with age-outs" do
    survey = @sd.survey
    t1 = Time.now
    t2 = t1 + survey.day_length
    @sd.time_ranges = [TimeRange.new(t1, t2)]
    @sd.survey.samples_per_day.times do |num|
      assert @sd.has_time_for_another_question?
      @sd.scheduled_messages.create(
        survey_question: survey_questions(:test_what),
        aasm_state: 'aged_out',
        scheduled_at: t1)
    end
    refute @sd.has_time_for_another_question?
  end

  test "minimum time to next question" do
    survey = @sd.participant.survey
    min_time = (survey.mean_minutes_between_samples - survey.sample_minutes_plusminus).minutes
    assert_equal 0, @sd.minimum_time_to_next_question
    @sd.scheduled_messages.create(
      survey_question: survey_questions(:test_what),
      scheduled_at: @sd.time_ranges.first.first + 10.minutes,
      aasm_state: 'delivered')

    min_time = (survey.mean_minutes_between_samples - survey.sample_minutes_plusminus).minutes
    assert_equal min_time, @sd.minimum_time_to_next_question
  end

  test "maximum time to next question" do
    survey = @sd.participant.survey
    max_time = (survey.mean_minutes_between_samples + survey.sample_minutes_plusminus).minutes
    assert_equal max_time, @sd.maximum_time_to_next_question
    @sd.scheduled_messages.create(
      survey_question: survey_questions(:test_what),
      scheduled_at: @sd.time_ranges.first.first + 10.minutes,
      aasm_state: 'delivered')

    max_time = (2*survey.mean_minutes_between_samples + survey.sample_minutes_plusminus).minutes
    assert_equal max_time, @sd.maximum_time_to_next_question
  end

  test "random time for next question is soon" do
    @sd = schedule_days(:test_day_1)
    puts @sd.random_time_for_next_question
    assert(@sd.random_time_for_next_question >= Time.now)
  end
end
