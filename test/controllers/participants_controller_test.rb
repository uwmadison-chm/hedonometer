# -*- encoding : utf-8 -*-
require 'test_helper'

class ParticipantsControllerTest < ActionController::TestCase
  def setup
    # Yes, this is bogus. It doesn't matter for these purposes.
    twilio_mock(example_create_message_response)
    super
  end

  def teardown
    WebMock.reset!
    super
  end

  def example_create_message_response
<<-resp
{
    "account_sid": "AC5ef872f6da5a21de157d80997a64bd33",
    "api_version": "2010-04-01",
    "body": "Jenny please?! I love you <3",
    "date_created": "Wed, 18 Aug 2010 20:01:40 +0000",
    "date_sent": null,
    "date_updated": "Wed, 18 Aug 2010 20:01:40 +0000",
    "direction": "outbound-api",
    "from": "+14158141829",
    "price": null,
    "sid": "SM90c6fc909d8504d45ecdb3a3d5b3556e",
    "status": "queued",
    "to": "+14159352345",
    "uri": "/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages/SM90c6fc909d8504d45ecdb3a3d5b3556e.json"
}
resp
  end

  def params_for_create
    {
      :participant => {:phone_number => '(608) 555-9999'},
      :survey_id => surveys(:test)
    }
  end

  def params_for_find
    {
      :participant => {:phone_number => '(608) 555-1212'},
      :survey_id => surveys(:test)
    }
  end

  test "participant should create" do
    post :create, params_for_create
    assert_response :success
    assert_not_nil assigns(:participant)
    refute assigns(:participant).new_record?
  end

  test "participant should not create duplicate" do
    post :create, params_for_create
    assert_response :success
    post :create, params_for_create
    assert_response 409
  end

  test "send login code succeeds" do
    post :send_login_code, params_for_find
    assert_response :success
  end

  test "send login code creates outgoing text message" do
    assert_changes surveys(:test).outgoing_text_messages, :count, 1 do
      post :send_login_code, params_for_find
    end
  end

  test "send login code 404s if we can't find" do
    bp = params_for_create
    bp[:participant][:phone_number] = '1'
    post :send_login_code, bp
    assert_response :not_found
  end
end
