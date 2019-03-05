require 'test_helper'

class GameSurveyTest < ActiveSupport::TestCase
  def setup
    @survey = surveys(:game)
    @ppt = participants(:ppt3)
  end

  test "schedule works" do
    q = @survey.schedule_participant! @ppt
    assert_match(/Please take this survey now/, q.message_text)
  end

  test "schedule initializes game state" do
    @survey.schedule_participant! @ppt
    assert_equal({}, @ppt.state['game_completed'])
    assert_equal(0, @ppt.state['game_balance'])
  end

  test "when game time is ready prompts participant to play" do
    @survey.schedule_participant! @ppt
    @day = schedule_days(:ppt3_test_day_1)
    @ppt.state['game_time'][@day.id.to_s] = Time.now - 5.minutes
    @ppt.save!
    q = @survey.schedule_participant! @ppt
    assert_match(/Do you have time to play/, q.message_text)
  end
end

