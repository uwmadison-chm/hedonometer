require 'test_helper'

class ScheduledMessagesControllerTest < ActionController::TestCase
  test "current message should redirect" do
    m = scheduled_messages(:message_2)
    m.scheduled_at = Time.now - 10.minutes
    m.save!
    post :show, params: {id: m.id}
    assert_redirected_to %r(qualtrics.com)
    refute assigns(:expired_string)
  end

  test "current message with overridden destination url should redirect to that" do
    m = scheduled_messages(:message_2)
    m.scheduled_at = Time.now - 10.minutes
    m.destination_url = "http://horse.horse/"
    m.save!
    post :show, params: {id: m.id}
    assert_redirected_to 'http://qualtrics.com/test?PID=df-5567'
  end

  test "older than 30 minutes message should show expired message" do
    m = scheduled_messages(:message_1)
    m.scheduled_at = Time.now - 40.minutes
    m.save!
    post :show, params: {id: scheduled_messages(:message_1).id}
    assert_response :success
    assert_select 'h3', /expired \d+ minutes ago/
  end

  test "not found message should show expired with a 404" do
    post :show, params: {id: 99999}
    assert_response :not_found
    assert_select 'h3', /expired/
  end
end
