# -*- encoding : utf-8 -*-
require 'test_helper'

class ParticipantTest < ActiveSupport::TestCase

  def create_params
    {
      phone_number: '608-555-9999',
      schedule_start_date: '2014-01-01',
      schedule_time_after_midnight: 0
    }
  end

  test "participants get their time zone copied" do
    p = surveys(:test).participants.build(phone_number: '1')
    p.valid?
    refute_nil p.time_zone
    assert_equal surveys(:test).time_zone, p.time_zone
  end

  test "participants need schedule data at creation time" do
    p = surveys(:test).participants.build(phone_number: '1')
    refute p.valid?, "Should not be valid!"
    refute_empty p.errors[:schedule_start_date], "No error on schedule_start_date"
    refute_empty p.errors[:schedule_time_after_midnight], "No error on schedule_time_after_midnight"
    p.schedule_start_date = '2014-01-01'
    p.schedule_time_after_midnight = 0
    assert p.valid?
  end

  test "creating a participant creates a schedule and schedules a message" do
    p = surveys(:test).participants.create(create_params)
    refute_empty p.schedule_days
    refute_empty p.schedule_days.first.scheduled_messages
  end

  test "schedule_human_time_after_midnight sets schedule_start_date" do
    p = Participant.new
    p.schedule_human_time_after_midnight = "8:00"
    assert_equal p.schedule_time_after_midnight, 8*60*60 # It's in seconds
  end

  test "participants need schedule data if updating with requests_new_schedule" do
    p = participants(:ppt1)
    p.requests_new_schedule = true
    refute p.valid?
    refute_empty p.errors[:schedule_start_date], "No error on schedule_start_date"
    refute_empty p.errors[:schedule_time_after_midnight], "No error on schedule_time_after_midnight"
    p.requests_new_schedule = false
    assert p.valid?
  end

  test "schedule days TimeRanges depend on ppt time zones" do
    s = surveys(:test)
    p1 = s.participants.create(
      phone_number: '608-555-9999', schedule_start_date: Date.today,
      schedule_time_after_midnight: 9.hours.to_i, time_zone: "America/Chicago")
    p1.rebuild_schedule_days!
    p2 = s.participants.create(
      phone_number: '608-555-9998', schedule_start_date: Date.today,
      schedule_time_after_midnight: 9.hours.to_i, time_zone: "Pacific/Midway")
    p2.rebuild_schedule_days!
    p1_tr = p1.schedule_days.first.time_ranges.first
    p2_tr = p2.schedule_days.first.time_ranges.first

    refute_equal p1_tr.first, p2_tr.first
  end

  test "participants are generated with login codes" do
    p = surveys(:test).participants.create(create_params)
    refute p.new_record?, p.errors.full_messages
    assert_equal p.login_code.length, Participant::LOGIN_CODE_LENGTH
  end

  test "phone numbers get serialized" do
    p = surveys(:test).participants.create(create_params)
    assert_equal PhoneNumber, p.phone_number.class
  end

  test "phone numbers load serialized" do
    assert_equal PhoneNumber, participants(:ppt1).phone_number.class
  end

  test "participant authentication works" do
    assert_nil Participant.authenticate('1', '1')
    assert_equal participants(:ppt1), Participant.authenticate('+16085551212', '12345')
    assert_equal participants(:ppt1), Participant.authenticate('6085551212', '12345')
    assert_equal participants(:ppt1), Participant.authenticate(PhoneNumber.new('6085551212'), '12345')
  end

  test "building schedule works" do
    p = participants(:ppt2)
    p.build_schedule_days(Date.today, 9.hours)
    assert_equal p.survey.sampled_days, p.schedule_days.length
  end

  test "creating schedule days" do
    s = surveys(:test)
    p = s.participants.create(
      phone_number: '608-555-9999', schedule_start_date: Date.today,
      schedule_time_after_midnight: 9.hours.to_i)
    p.rebuild_schedule_days!
    assert_equal s.sampled_days, p.schedule_days.length
    assert_equal Date.today, p.schedule_days.first.starts_at.to_date
  end

  test "can_schedule_days? method" do
    p = participants(:ppt1)
    refute p.can_schedule_days?
    p.schedule_start_date = Date.today
    refute p.can_schedule_days?
    p.schedule_time_after_midnight = 9.hours
    assert p.can_schedule_days?
    p.schedule_days.first.scheduled_messages.create!(
      survey_question: survey_questions(:test_what),
      scheduled_at: Time.now,
      aasm_state: 'delivered')
    refute p.can_schedule_days?
  end

  test "schedule days get rescheduled" do
    p = participants(:ppt2)
    p.schedule_start_date = Date.today
    p.schedule_time_after_midnight = 9.hours
    p.rebuild_schedule_days!
    assert_equal Date.today, p.schedule_days.first.starts_at.to_date
    p.schedule_start_date = Date.tomorrow
    p.rebuild_schedule_days!
    p.reload
    assert_equal p.survey.sampled_days, p.schedule_days.length
    assert_equal Date.tomorrow, p.schedule_days.first.starts_at.to_date
  end

  test "first potential schedule day" do
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

  test "advancing schedule days after messages are done" do
    ppt = participants(:ppt1)
    sday = ppt.survey.advance_to_day_with_time_for_message! ppt
    assert_equal schedule_days(:test_day_1), sday
    assert_equal 'running', sday.aasm_state
    ppt.survey.samples_per_day.times do
      sday.scheduled_messages.create!(
        aasm_state: 'delivered', survey_question: survey_questions(:test_what), scheduled_at: Time.now)
    end
    sday = ppt.survey.advance_to_day_with_time_for_message! ppt
    assert_equal schedule_days(:test_day_2), sday
    ppt.survey.samples_per_day.times do
      sday.scheduled_messages.create!(
        aasm_state: 'delivered', survey_question: survey_questions(:test_what), scheduled_at: Time.now)
    end
    assert_nil ppt.survey.advance_to_day_with_time_for_message! ppt
    assert_equal ppt.schedule_days.count, ppt.schedule_days.finished.count
  end

  test "can find text messages" do
    all_messages = participants(:ppt1).text_messages
    assert_equal 2, all_messages.length
  end

  test "schedule days have correct length even if they go over midnight" do
    p = participants(:ppt2)
    p.schedule_start_date = Date.today
    p.schedule_time_after_midnight = 20.hours
    p.rebuild_schedule_days!
    difference = p.schedule_days.first.ends_at - p.schedule_days.first.starts_at
    assert_equal p.survey.day_length, difference
  end
end
