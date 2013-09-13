# -*- encoding : utf-8 -*-
require 'test_helper'

class ParticipantTest < ActiveSupport::TestCase
  test "participants get their time zone copied" do
    p = surveys(:test).participants.build(phone_number: '1')
    p.valid?
    refute_nil p.time_zone
    assert_equal surveys(:test).time_zone, p.time_zone
  end

  test "participants are generated with login codes" do
    p = surveys(:test).participants.create(phone_number: '1')
    refute p.new_record?, p.errors.full_messages
    assert_equal p.login_code.length, Participant::LOGIN_CODE_LENGTH
  end

  test "phone numbers get serialized" do
    p = surveys(:test).participants.create(phone_number: '608-555-9999')
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

  test "getting new question" do
    p = participants(:ppt1)
    sq = p.choose_question
    unused = p.question_chooser_state[:unused_ids]
    refute_nil unused
    assert_equal (p.survey.survey_questions.count - 1), unused.length
    refute_includes p.question_chooser_state[:unused_ids], sq.id
  end

  test "creating schedule days" do
    s = surveys(:test)
    p = s.participants.create(
      phone_number: '608-555-9999', schedule_start_date: Date.today,
      schedule_time_after_midnight: 9.hours)
    p.rebuild_schedule_days!
    assert_equal s.sampled_days, p.schedule_days.length
    assert_equal p.schedule_days.first.date, Date.today
  end

  test "schedule days get rescheduled" do
    p = participants(:ppt2)
    p.schedule_start_date = Date.today
    p.schedule_time_after_midnight = 9.hours
    p.rebuild_schedule_days!
    assert_equal p.schedule_days.first.date, Date.today
    p.schedule_start_date = Date.tomorrow
    p.rebuild_schedule_days!
    p.reload
    assert_equal p.survey.sampled_days, p.schedule_days.length
    assert_equal p.schedule_days.first.date, Date.tomorrow
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

  test "advance to first potential day" do
    ppt = participants(:ppt1)
    sday = ppt.schedule_days.advance_to_day_with_time_for_question!
    assert_equal schedule_days(:test_day_1), sday
    assert_equal 'running', sday.aasm_state
    ppt.survey.samples_per_day.times do
      sday.scheduled_questions.create!(
        aasm_state: 'delivered', survey_question: survey_questions(:test_what), scheduled_at: Time.now)
    end
    sday = ppt.schedule_days.advance_to_day_with_time_for_question!
    assert_equal schedule_days(:test_day_2), sday
    ppt.survey.samples_per_day.times do
      sday.scheduled_questions.create!(
        aasm_state: 'delivered', survey_question: survey_questions(:test_what), scheduled_at: Time.now)
    end
    assert_nil ppt.schedule_days.advance_to_day_with_time_for_question!
    assert_equal ppt.schedule_days.count, ppt.schedule_days.finished.count
  end

  test "current or new question basically works" do
    ppt = participants(:ppt1)
    q = ppt.current_question_or_new
    refute_nil q
  end

  test "current or new doesn't find delivered questions" do
    ppt = participants(:ppt1)
    sday = ppt.schedule_days.first
    sq = sday.scheduled_questions.create!(
      survey_question: survey_questions(:test_what), scheduled_at: Time.now, aasm_state: 'delivered')
    refute_equal sq, ppt.current_question_or_new
  end

  test "schedule survey question works" do
    ppt = participants(:ppt1)
    q = ppt.schedule_survey_question
    refute_nil q
  end

  test "schedule and save works" do
    ppt = participants(:ppt1)
    q = ppt.schedule_survey_question_and_save!
    refute q.new_record?
  end
end
