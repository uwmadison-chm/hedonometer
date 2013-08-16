require 'test_helper'

class ScheduledQuestionTest < ActiveSupport::TestCase
  test "undelivered when delivered_at is nil" do
    sq = ScheduledQuestion.new
    assert sq.undelivered?
    sq.delivered_at = Time.now
    refute sq.undelivered?
  end

  test "delivery is due when time is past scheduled_at" do
    sq = ScheduledQuestion.new scheduled_at: (Time.now - 1.minute)
    assert sq.delivery_due?
    sq.scheduled_at = (Time.now + 1.minute)
    refute sq.delivery_due?
  end

  test "older than x seconds" do
    sq = ScheduledQuestion.new scheduled_at: (Time.now - 1.minute)
    assert sq.younger_than?(30.seconds)
    refute sq.younger_than?(2.minutes)
  end

  test "can be delivered now" do
    sq = ScheduledQuestion.new scheduled_at: Time.now - 1.minute
    assert sq.can_be_delivered_now?(30.seconds)
    refute sq.can_be_delivered_now?(2.minutes)
    sq.delivered_at = Time.now
    refute sq.can_be_delivered_now?(30.seconds)
    sq.delivered_at = nil
    sq.scheduled_at = Time.now + 1.minute
    refute sq.can_be_delivered_now?(30.seconds)
  end
end
