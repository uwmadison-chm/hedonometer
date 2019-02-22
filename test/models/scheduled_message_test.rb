require 'test_helper'

class ScheduledMessageTest < ActiveSupport::TestCase
  class MockMessage
    attr_accessor :delivered
    def initialize
      @delivered = false
    end
    def deliver_and_save!
      @delivered = true
    end
  end

  test "is valid with message and no question" do
    day = schedule_days(:test_day_1)
    sm = ScheduledMessage.new schedule_day: day, scheduled_at: Time.now, message_text: "Hello there"
    assert sm.valid?, 'scheduled message is valid with no message or question'
  end

  test "requires message or linked question" do
    day = schedule_days(:test_day_1)
    sm = ScheduledMessage.new schedule_day: day, scheduled_at: Time.now
    refute sm.valid?, 'scheduled message is valid with no message or question'
    assert_not_nil sm.errors[:base], 'no validation error for missing message/question'
  end

  test "undelivered when delivered_at is nil" do
    sm = ScheduledMessage.new
    assert sm.undelivered?
    sm.delivered_at = Time.now
    refute sm.undelivered?
  end

  test "delivery is due when time is past scheduled_at" do
    sm = ScheduledMessage.new scheduled_at: (Time.now - 1.minute)
    assert sm.delivery_due?
    sm.scheduled_at = (Time.now + 1.minute)
    refute sm.delivery_due?
  end

  test "younger than" do
    sm = ScheduledMessage.new scheduled_at: 1.minute.ago
    assert sm.younger_than?(30.seconds)
    refute sm.younger_than?(90.minutes)
  end

  test "too old to deliver" do
    sm = schedule_days(:test_day_1).scheduled_messages.build
    survey = schedule_days(:test_day_1).participant.survey
    sm.scheduled_at = Time.now
    refute sm.too_old_to_deliver?
    sm.scheduled_at = Time.now - (survey.mininum_intersample_period+1.second)
    assert sm.too_old_to_deliver?
  end

  test "can be delivered now" do
    sm = schedule_days(:test_day_1).scheduled_messages.build(scheduled_at: Time.now - 1.minute)
    ##binding.pry
    assert sm.can_be_delivered_now?
    sm.delivered_at = Time.now
    refute sm.can_be_delivered_now?
    sm.delivered_at = nil
    sm.scheduled_at = Time.now + 1.minute
    refute sm.can_be_delivered_now?
  end

  test "deliver and save if possible" do
    msg = MockMessage.new
    q = survey_questions(:test_what)
    survey = schedule_days(:test_day_1).participant.survey
    sm = schedule_days(:test_day_1).scheduled_messages.build(
      scheduled_at: Time.now - 1.minute,
      survey_question: q)
    sm.deliver_and_save_if_possible!(msg)
    assert_equal 'delivered', sm.aasm_state
    sm.delete
    sm = schedule_days(:test_day_1).scheduled_messages.create(
      scheduled_at: Time.now - (survey.mininum_intersample_period+1.second),
      survey_question: q)
    assert_equal 'scheduled', sm.aasm_state
    sm.deliver_and_save_if_possible!(msg)
    assert_equal 'aged_out', sm.aasm_state
  end

  test "deliver won't send to inactive participants" do
    msg = MockMessage.new
    q = survey_questions(:test_what)
    ppt = schedule_days(:test_day_1).participant
    ppt.active = false
    ppt.save
    schedule_days(:test_day_1).participant.survey
    sm = schedule_days(:test_day_1).scheduled_messages.build(
      scheduled_at: Time.now - 1.minute,
      survey_question: q)
    sm.deliver_and_save_if_possible!(msg)
    refute msg.delivered, "Message should not be delivered"
    assert sm.participant_inactive?
  end

  test "completed" do
    sm = ScheduledMessage.new
    refute sm.completed?
    sm.delivered_at = Time.now
    assert sm.completed?
    sm.delivered_at = nil
    sm.aasm_state = "aged_out"
    assert sm.completed?
    sm.aasm_state = "participant_inactive"
    assert sm.completed?
    sm.aasm_state = "scheduled"
    refute sm.completed?
  end
end
