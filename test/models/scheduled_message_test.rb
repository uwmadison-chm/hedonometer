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

  test "undelivered when delivered_at is nil" do
    sq = ScheduledMessage.new
    assert sq.undelivered?
    sq.delivered_at = Time.now
    refute sq.undelivered?
  end

  test "delivery is due when time is past scheduled_at" do
    sq = ScheduledMessage.new scheduled_at: (Time.now - 1.minute)
    assert sq.delivery_due?
    sq.scheduled_at = (Time.now + 1.minute)
    refute sq.delivery_due?
  end

  test "younger than" do
    sq = ScheduledMessage.new scheduled_at: 1.minute.ago
    assert sq.younger_than?(30.seconds)
    refute sq.younger_than?(90.minutes)
  end

  test "too old to deliver" do
    sq = schedule_days(:test_day_1).scheduled_messages.build
    survey = schedule_days(:test_day_1).participant.survey
    sq.scheduled_at = Time.now
    refute sq.too_old_to_deliver?
    sq.scheduled_at = Time.now - (survey.mininum_intersample_period+1.second)
    assert sq.too_old_to_deliver?
  end

  test "can be delivered now" do
    sq = schedule_days(:test_day_1).scheduled_messages.build(scheduled_at: Time.now - 1.minute)
    ##binding.pry
    assert sq.can_be_delivered_now?
    sq.delivered_at = Time.now
    refute sq.can_be_delivered_now?
    sq.delivered_at = nil
    sq.scheduled_at = Time.now + 1.minute
    refute sq.can_be_delivered_now?
  end

  test "deliver and save if possible" do
    msg = MockMessage.new
    q = survey_questions(:test_what)
    survey = schedule_days(:test_day_1).participant.survey
    sq = schedule_days(:test_day_1).scheduled_messages.build(
      scheduled_at: Time.now - 1.minute,
      survey_question: q)
    sq.deliver_and_save_if_possible!(msg)
    assert_equal 'delivered', sq.aasm_state
    sq.delete
    sq = schedule_days(:test_day_1).scheduled_messages.create(
      scheduled_at: Time.now - (survey.mininum_intersample_period+1.second),
      survey_question: q)
    assert_equal 'scheduled', sq.aasm_state
    sq.deliver_and_save_if_possible!(msg)
    assert_equal 'aged_out', sq.aasm_state
  end

  test "deliver won't send to inactive participants" do
    msg = MockMessage.new
    q = survey_questions(:test_what)
    ppt = schedule_days(:test_day_1).participant
    ppt.active = false
    ppt.save
    schedule_days(:test_day_1).participant.survey
    sq = schedule_days(:test_day_1).scheduled_messages.build(
      scheduled_at: Time.now - 1.minute,
      survey_question: q)
    sq.deliver_and_save_if_possible!(msg)
    refute msg.delivered, "Message should not be delivered"
    assert sq.participant_inactive?
  end

  test "completed" do
    sq = ScheduledMessage.new
    refute sq.completed?
    sq.delivered_at = Time.now
    assert sq.completed?
    sq.delivered_at = nil
    sq.aasm_state = "aged_out"
    assert sq.completed?
    sq.aasm_state = "participant_inactive"
    assert sq.completed?
    sq.aasm_state = "scheduled"
    refute sq.completed?
  end
end
