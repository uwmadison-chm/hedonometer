require 'test_helper'

class ScheduledMessagesControllerTest < ActionController::TestCase
  test "current message should redirect" do
    post :show, params: {id: scheduled_messages(:message_2).id}
    assert_redirected_to %r(\Ahttp://something)
    refute assigns(:expired_string)
  end

  test "older than 30 minutes message should show expired message" do
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
