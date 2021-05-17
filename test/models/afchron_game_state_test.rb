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
    assert_equal(1, @state.surveys_for_day(@day).count)
    assert(@state.surveys_for_day(@day).first <= Time.now + 15.minutes)
  end

  test "with existing surveys splits time" do
    @state.state['game_time'] = Time.now + 24.hours
    @state.set_surveys_for_day @day, [
      @day.starts_at + 1.hour,
      @day.starts_at + 2.hour,
    ]
    q = @state.take_action!
    assert_match(/Please take this survey now/, q.message_text)
    surveys_sent = @state.surveys_for_day @day
    assert_equal(3, surveys_sent.count)
    assert(surveys_sent.last > @day.starts_at + 2.hour + 30.minutes)
  end

  test "only schedules once" do
    assert_equal(0, Delayed::Job.count)
    @state.state['game_time'] = Time.now + 24.hours
    @state.set_surveys_for_day @day, [
      @day.starts_at + 1.hour,
      @day.starts_at + 2.hour,
    ]
    @state.take_action!
    @state.take_action!
    assert_equal(1, Delayed::Job.count)
  end

  test "with game already done" do
    @state.state['game_time'] = @day.starts_at + 1.hour
    @state.state["game_completed_results"].push true
    @state.state["game_completed_dayid"].push @day.id
    @state.state["game_completed_time"].push (@day.starts_at + 2.hours)
    @state.set_surveys_for_day @day, [
      @day.starts_at + 1.hour,
      @day.starts_at + 3.hours,
    ]
    q = @state.take_action!
    assert_match(/Please take this survey now/, q.message_text)
    surveys_sent = @state.surveys_for_day @day
    assert_equal(3, surveys_sent.count)
    assert(surveys_sent.last > @day.starts_at + 3.hour + 30.minutes)
  end

  test "completed day with game already done" do
    @state.state['game_time'] = @day.starts_at + 1.hour
    @state.state["game_completed_results"].push true
    @state.state["game_completed_dayid"].push @day.id
    @state.state["game_completed_time"].push (@day.starts_at + 2.hours)
    @state.set_surveys_for_day @day, [
      @day.starts_at + 1.hour,
      @day.starts_at + 2.hours,
      @day.starts_at + 3.hours,
      @day.starts_at + 4.hours,
      @day.starts_at + 5.hours,
      @day.starts_at + 6.hours,
      @day.starts_at + 7.hours,
      @day.starts_at + 8.hours,
    ]
    assert_equal(8, @state.surveys_for_day(@day).count)
    q = @state.take_action!
    assert_match(/Please take this survey now/, q.message_text)
    assert_equal(8, @state.surveys_for_day(@day).count)
    surveys_sent_tomorrow = @state.surveys_for_day @day2
    assert_equal(1, surveys_sent_tomorrow.count)
    assert(surveys_sent_tomorrow.last > @day2.starts_at)
  end

  test "game starts at a random time on day 2" do
    @state.state['game_time'] = @day.starts_at + 1.hour
    @state.state["game_completed_results"].push true
    @state.state["game_completed_dayid"].push @day.id
    @state.state["game_completed_time"].push (@day.starts_at + 2.hours)
    @state.set_surveys_for_day @day, [
      @day.starts_at + 1.hour,
      @day.starts_at + 2.hours,
      @day.starts_at + 3.hours,
      @day.starts_at + 4.hours,
      @day.starts_at + 5.hours,
      @day.starts_at + 6.hours,
      @day.starts_at + 7.hours,
      @day.starts_at + 8.hours,
    ]
    assert_equal(8, @state.surveys_for_day(@day).count)
    q = @state.take_action!
    assert_match(/Please take this survey now/, q.message_text)
    assert_equal(8, @state.surveys_for_day(@day).count)
    assert(@state.state['game_time'] > @day2.starts_at + 30.minutes)

    # TODO: Even though this is passing, we need to check on N runs that some 
    # percent of them land in the later half of the day, because the scheduler 
    # is picking 15 minutes, the first available time, far too often on days 
    # after the first
  end

  test "one survey left with game already done does not schedule past 12 hours" do
    @state.state['game_time'] = @day.starts_at + 1.hour
    @state.state["game_completed_results"].push true
    @state.state["game_completed_dayid"].push @day.id
    @state.state["game_completed_time"].push (@day.starts_at + 2.hours)
    @state.set_surveys_for_day @day, [
      @day.starts_at + 1.hour,
      @day.starts_at + 3.hours,
      @day.starts_at + 5.hours,
      @day.starts_at + 7.hours,
      @day.starts_at + 9.hours,
      @day.starts_at + 10.hours,
      @day.starts_at + 11.hours,
    ]
    q = @state.take_action!
    assert_match(/Please take this survey now/, q.message_text)
    surveys_sent = @state.surveys_for_day @day
    assert_equal(8, surveys_sent.count)
    assert(surveys_sent.last <= @day2.ends_at)
    surveys_sent_tomorrow = @state.surveys_for_day @day2
    assert_equal(0, surveys_sent_tomorrow.count)
  end

  test "full day with skipped game" do
    @state.state['game_time'] = @day.starts_at + 1.hour
    @state.set_surveys_for_day @day, [
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
    surveys_sent = @state.surveys_for_day @day
    assert_equal(8, surveys_sent.count)
    assert_kind_of(Time, surveys_sent.last)
    surveys_sent_tomorrow = @state.surveys_for_day @day2
    assert_equal(1, surveys_sent_tomorrow.count)
    assert(surveys_sent_tomorrow.last > @day2.starts_at)
  end

  test "ready for game" do
    @state.state['game_time'] = @day.starts_at - 1.hour
    q = @state.take_action!
    assert_match(/Do you have time to play a game/, q.message_text)
  end

  test "no game for me" do
    @state.state['game_time'] = @day.starts_at - 1.hour
    @state.take_action!
    @state.incoming_message "no"
    assert(@state.state['game_time'] > Time.now + 20.minutes)
    assert(@state.none?)
  end

  test "yes I will play a game" do
    @state.state['game_time'] = @day.starts_at - 1.hour
    @state.take_action!
    q = @state.incoming_message "yes"
    assert_match(/We generated a number/, q.message_text)
    assert(@state.waiting_number?)
  end

  test "guessed high" do
    @state.state['game_time'] = @day.starts_at - 1.hour
    @state.take_action!
    @state.incoming_message "yes"
    q = @state.incoming_message "high"
    assert_match(/You guessed/, q.message_text)
    assert(@state.game_surveying?)
  end

  test "guessed low" do
    @state.state['game_time'] = @day.starts_at - 1.hour
    @state.take_action!
    @state.incoming_message "yes"
    q = @state.incoming_message "low"
    assert_match(/You guessed/, q.message_text)
    assert(@state.game_surveying?)
  end

  test "guessed other" do
    @state.state['game_time'] = @day.starts_at - 1.hour
    @state.take_action!
    @state.incoming_message "yes"
    q = @state.incoming_message "other"
    assert_match(/You need to pick 'high' or 'low'/, q.message_text)
    assert(@state.waiting_number?)
  end

  test "at beginning of game sampling" do
    @state.ask_to_play
    @state.play
    @state.game_send_result! "high"
    short_surveys = @state.game_surveys_for_day(@day)
    assert_equal(1, short_surveys.count)
    assert_kind_of(Time, short_surveys.last)
  end

  test "in middle of game sampling" do
    @state.ask_to_play
    @state.play
    @state.game_send_result! "high"
    q = @state.game_gather_data!
    assert_equal(2, @state.game_surveys_for_day(@day).count)
    assert_match(/Please take this short survey now/, q.message_text)
  end

  test "at end of game sampling" do
    @state.ask_to_play
    @state.play
    @state.game_send_result! "high"
    @state.set_game_surveys_for_day @day, [
      Time.now + 2.minutes,
      Time.now + 4.minutes,
      Time.now + 6.minutes,
      Time.now + 8.minutes,
      Time.now + 10.minutes,
    ]
    q = @state.game_gather_data!
    assert_equal(6, @state.game_surveys_for_day(@day).count)
    assert(q.scheduled_at >= Time.now + 10.minutes)
    assert(@state.game_surveying?)
    surveys_sent = @state.surveys_for_day @day
    assert_empty(surveys_sent)
  end

  test "after game sampling" do
    @state.ask_to_play
    @state.play
    @state.game_send_result! "high"
    @state.set_game_surveys_for_day @day, [
      Time.now + 2.minutes,
      Time.now + 4.minutes,
      Time.now + 6.minutes,
      Time.now + 8.minutes,
      Time.now + 10.minutes,
      Time.now + 12.minutes,
    ]
    q = @state.game_gather_data!
    assert_equal(6, @state.game_surveys_for_day(@day).count)
    assert(@state.none?)
    surveys_sent = @state.surveys_for_day @day
    assert_equal(1, surveys_sent.count)
    assert_match(/Please take this survey now/, q.message_text)
  end


end


