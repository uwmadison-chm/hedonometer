# -*- encoding : utf-8 -*-
require 'test_helper'

class ParticipantsControllerTest < ActionController::TestCase
  def setup
    twilio_mock(TwilioResponses.create_sms)
    super
  end

  def teardown
    WebMock.reset!
    super
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
