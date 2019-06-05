require 'test_helper'

class AfchronGameStateTest < ActiveSupport::TestCase
  def setup
    @survey = surveys(:game)
    @ppt = participants(:ppt3)
    @day = schedule_days(:ppt3_test_day_1)
    @day2 = schedule_days(:ppt3_test_day_2)
    @survey.prepare_game_state @ppt
    @state = @ppt.participant_state
  end

  test "before game_time" do
    @state.state['game_time'] = Time.now + 24.hours
    q = @state.take_action!
    assert_match(/Please take this survey now/, q.message_text)
    assert_equal(1, @state.state["surveys_sent_by_day"][@day.id.to_s].count)
  end

  test "with existing surveys splits time" do
    @state.state['game_time'] = Time.now + 24.hours
    @state.state['surveys_sent_by_day'][@day.id.to_s] = [
      @day.starts_at + 1.hour,
      @day.starts_at + 2.hour,
    ]
    q = @state.take_action!
    assert_match(/Please take this survey now/, q.message_text)
    surveys_sent = @state.state["surveys_sent_by_day"][@day.id.to_s]
    assert_equal(3, surveys_sent.count)
    assert(surveys_sent.last > @day.starts_at + 2.hour + 30.minutes)
  end

  test "with game already done" do
    @state.state['game_time'] = @day.starts_at + 1.hour
    @state.state["game_completed_results"].push true
    @state.state["game_completed_dayid"].push @day.id
    @state.state["game_completed_time"].push (@day.starts_at + 2.hours)
    @state.state['surveys_sent_by_day'][@day.id.to_s] = [
      @day.starts_at + 1.hour,
      @day.starts_at + 3.hours,
    ]
    q = @state.take_action!
    assert_match(/Please take this survey now/, q.message_text)
    surveys_sent = @state.state["surveys_sent_by_day"][@day.id.to_s]
    assert_equal(3, surveys_sent.count)
    assert(surveys_sent.last > @day.starts_at + 3.hour + 30.minutes)
  end

  test "completed day with game already done" do
    @state.state['game_time'] = @day.starts_at + 1.hour
    @state.state["game_completed_results"].push true
    @state.state["game_completed_dayid"].push @day.id
    @state.state["game_completed_time"].push (@day.starts_at + 2.hours)
    @state.state['surveys_sent_by_day'][@day.id.to_s] = [
      @day.starts_at + 1.hour,
      @day.starts_at + 2.hours,
      @day.starts_at + 3.hours,
      @day.starts_at + 4.hours,
      @day.starts_at + 5.hours,
      @day.starts_at + 6.hours,
      @day.starts_at + 7.hours,
      @day.starts_at + 8.hours,
    ]
    q = @state.take_action!
    assert_match(/Please take this survey now/, q.message_text)
    surveys_sent = @state.state["surveys_sent_by_day"][@day.id.to_s]
    assert_equal(8, surveys_sent.count)
    surveys_sent_tomorrow = @state.state["surveys_sent_by_day"][@day2.id.to_s]
    assert_equal(1, surveys_sent_tomorrow.count)
    assert(surveys_sent_tomorrow.last > @day2.starts_at)
  end

  test "full day with skipped game" do
    @state.state['game_time'] = @day.starts_at + 1.hour
    @state.state['surveys_sent_by_day'][@day.id.to_s] = [
      @day.starts_at + 1.hour,
      @day.starts_at + 2.hours,
      @day.starts_at + 3.hours,
      @day.starts_at + 4.hours,
      @day.starts_at + 5.hours,
      @day.starts_at + 6.hours,
      @day.starts_at + 7.hours,
      @day.starts_at + 8.hours,
    ]
    q = @state.take_action!
    assert_match(/Please take this survey now/, q.message_text)
    surveys_sent = @state.state["surveys_sent_by_day"][@day.id.to_s]
    assert_equal(8, surveys_sent.count)
    surveys_sent_tomorrow = @state.state["surveys_sent_by_day"][@day2.id.to_s]
    assert_equal(1, surveys_sent_tomorrow.count)
    assert(surveys_sent_tomorrow.last > @day2.starts_at)
  end

  test "ready for game" do
    @state.state['game_time'] = @day.starts_at - 1.hour
    q = @state.take_action!
    assert_match(/Do you have time to play a game/, q.message_text)
  end

  test "at beginning of game sampling" do
    @state.ask_to_play
    @state.play
    @state.game_send_result! "high"
    assert_equal(1, @state.state['game_survey_count'])
  end

  test "in middle of game sampling" do
    @state.ask_to_play
    @state.play
    @state.game_send_result! "high"
    q = @state.take_action!
    assert_equal(2, @state.state['game_survey_count'])
    assert_match(/Please take this short survey now/, q.message_text)
  end

  test "at end of game sampling" do
    @state.ask_to_play
    @state.play
    @state.game_send_result! "high"
    @state.state['game_survey_count'] = 6
    q = @state.take_action!
    assert_equal(6, @state.state['game_survey_count'])
    assert_equal("none", @state.aasm_state)
    surveys_sent = @state.state["surveys_sent_by_day"][@day.id.to_s]
    assert_equal(1, surveys_sent.count)
    assert_match(/Please take this survey now/, q.message_text)
  end

end


