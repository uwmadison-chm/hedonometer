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

  test "participant state values persists balance" do
    @survey.schedule_participant! @ppt
    @ppt.state.game_balance = 10
    @ppt.save!
    db_ppt = Participant.find(@ppt.id)
    assert_equal(10, db_ppt.state.game_balance)
  end

  test "participant state values persists times" do
    skip("Time comes back as a string")
    @survey.schedule_participant! @ppt
    secret = Time.now - 77.hours
    @ppt.state.game_time = secret
    @ppt.save!
    db_ppt = Participant.find(@ppt.id)
    assert_equal(secret, db_ppt.state.game_time)
  end

  test "participant state aasm persists" do
    @survey.prepare_game_state @ppt
    @ppt.state.ask_to_play!
    @ppt.save!
    db_ppt = Participant.find(@ppt.id)
    assert_equal(:waiting_asked, db_ppt.state.current_state)
  end

  test "when it is not yet time TO GAME, just sends survey" do
    @survey.prepare_game_state @ppt
    @ppt.state.game_time = Time.now + 1.hours
    @ppt.save!
    assert_equal(:none, @ppt.state.current_state)
    q = @survey.schedule_participant! @ppt

    assert_equal(:none, @ppt.state.current_state)
    assert_match(/Please take this survey now/, q.message_text)
  end

  test "when game time is ready prompts participant to play" do
    @survey.prepare_game_state @ppt
    @ppt.state.game_time = Time.now - 1.hours
    @ppt.save!
    assert_equal(:none, @ppt.state.current_state)
    q = @survey.schedule_participant! @ppt

    assert_equal(:waiting_asked, @ppt.state.current_state)
    assert_match(/Do you have time to play/, q.message_text)
  end

  test "participant responds in time to play" do
    @survey.prepare_game_state @ppt
    @ppt.state.game_time = Time.now - 1.hours
    @ppt.save!
    @survey.schedule_participant! @ppt
    @ppt.state.incoming_message "yes"
    assert_equal(:waiting_number, @ppt.state.current_state)
  end

  test "participant times out" do
    skip("Not sure how to test timeouts")
  end

end

