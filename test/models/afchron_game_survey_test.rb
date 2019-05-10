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
    Rails.logger.info("Got state: #{@ppt.state.inspect}")
    assert_kind_of(AfchronGameState, @ppt.state)
    assert_equal(0, @ppt.state.game_balance)
    assert_equal({}, @ppt.state.game_completed)
  end

  test "participant state values persists" do
    @survey.schedule_participant! @ppt
    @ppt.state.game_balance = 10
    @ppt.save!
    db_ppt = Participant.find(@ppt.id)
    assert_equal(10, db_ppt.state.game_balance)
  end

  test "participant state aasm persists" do
    @survey.schedule_participant! @ppt
    @ppt.state.ask_to_play!
    @ppt.save!
    db_ppt = Participant.find(@ppt.id)
    assert_equal(:asked_to_play, db_ppt.state.current_state)
  end

  test "when game time is ready prompts participant to play" do
    @day = schedule_days(:ppt3_test_day_1)
    @survey.prepare_game_state @ppt
    @ppt.state.game_time[@day.id.to_s] = Time.now - 5.minutes
    @ppt.save!
    assert_equal(:none, @ppt.state.current_state)
    q = @survey.schedule_participant! @ppt

    assert_match(/Do you have time to play/, q.message_text)
    assert_equal("waiting_asked", @ppt.state.aasm_state)
  end
end

