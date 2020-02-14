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

  test "older than 30 minutes message should show expired message" do
    m = scheduled_messages(:message_1)
    m.scheduled_at = Time.now - 40.minutes
    m.save!
    post :show, params: {id: scheduled_messages(:message_1).id}
    assert_response :success
    assert_select 'h3', /expired \d+ minutes ago/
  end

  test "custom expiry should show expired message" do
    m = scheduled_messages(:message_1)
    m.scheduled_at = Time.now - 10.minutes
    m.expires_at = Time.now - 5.minutes
    m.save!
    post :show, params: {id: scheduled_messages(:message_1).id}
    assert_response :success
    assert_select 'h3', /expired \d+ minutes ago/
  end

  test "custom expiry that's longer should redirect" do
    m = scheduled_messages(:message_1)
    m.scheduled_at = Time.now - 160.minutes
    m.expires_at = Time.now + 15.minutes
    m.save!
    post :show, params: {id: scheduled_messages(:message_1).id}
    assert_redirected_to %r(qualtrics.com)
    refute assigns(:expired_string)
  end


  test "not found message should show expired with a 404" do
    post :show, params: {id: 99999}
    assert_response :not_found
    assert_select 'h3', /expired/
  end

  test "generic completion page" do
    get :complete
    assert_response :success
    assert_select 'h3', /complete/
  end
end
