require 'test_helper'
require 'json'

class Admin::TwilioAccountsControllerTest < ActionController::TestCase

  def setup
    admin_login_as :nate
    super
  end

  def teardown
    WebMock.reset!
    super
  end

  test "login required" do
    admin_logout
    get :show, sid: 'test', auth_token: 'test', format: 'json'
    assert_response :redirect
  end

  test "get json for good account" do
    twilio_mock(TwilioResponses.incoming_phone_numbers(used_numbers))
    get :show, sid: 'test', auth_token: 'test', format: 'json'
    assert_response :success
    assert JSON.parse(response.body)
  end

  test "get error for bad account" do
    twilio_mock(TwilioResponses.auth_failure, 401)
    get :show, sid: 'test', auth_token: 'test', format: 'json'
    assert_response :unauthorized
  end

end
