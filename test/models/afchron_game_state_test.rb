require 'test_helper'

class AfchronGameStateTest < ActiveSupport::TestCase
  def setup
    @survey = surveys(:game)
    @ppt = participants(:ppt3)
    @day = schedule_days(:ppt3_test_day_1)
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
      @day.starts_at + 2.hour
    ]
    q = @state.take_action!
    assert_match(/Please take this survey now/, q.message_text)
    surveys_sent = @state.state["surveys_sent_by_day"][@day.id.to_s]
    assert_equal(3, surveys_sent.count)
    assert(surveys_sent.last > @day.starts_at + 2.hour + 30.minutes)
  end

  test "with game already done" do
    skip
  end

  test "full day with skipped game" do
    skip
  end

end


