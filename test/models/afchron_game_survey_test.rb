require 'test_helper'

class AfchronGameSurveyTest < ActiveSupport::TestCase
  def setup
    @survey = surveys(:game)
    @ppt = participants(:ppt3)
  end

  test "schedule works" do
    q = @survey.schedule_participant! @ppt
    assert_match(/Please take this survey now|Do you have time to play a game/, q.message_text)
  end

  test "schedule initializes game state" do
    @survey.schedule_participant! @ppt
    assert_kind_of(AfchronGameState, @ppt.state)
    assert_equal(0, @ppt.state.game_balance)
    assert_equal({}, @ppt.state.game_completed)
  end

  test "when game time is ready prompts participant to play" do
    @day = schedule_days(:ppt3_test_day_1)
    @survey.prepare_game_state @ppt
    @ppt.state.game_time[@day.id.to_s] = Time.now - 5.minutes
    @ppt.save!
    assert_equal("initial", @ppt.state.aasm_state)
    q = @survey.schedule_participant! @ppt

    assert_match(/Do you have time to play/, q.message_text)
    assert_equal("waiting_asked", @ppt.state.aasm_state)
  end
end

