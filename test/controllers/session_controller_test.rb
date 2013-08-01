# -*- encoding : utf-8 -*-
require 'test_helper'

class SessionControllerTest < ActionController::TestCase
  def params_for_login_code(survey_fixture_name, phone_number)
    {
      "participant"=>{
        "phone_number"=>phone_number,
        "login_code"=>""},
      "send_code"=>"Text me my login code!",
      "survey_id"=>surveys(survey_fixture_name).id
    }
  end

  def params_for_login(survey, phone_number, login_code)

  end

  test "login renders" do
    get :new, {survey_id: surveys(:test).id}
    assert_response :success
  end

  test "logout redirects to login" do
    get :destroy, {survey_id: surveys(:test).id}
    assert_response :redirect
    assert_redirected_to survey_login_path(surveys(:test))
  end

  test "send login code succeeds" do
    twilio_mock(TwilioResponses.create_sms)

    post :send_login_code, params_for_login_code(:test, participants(:ppt1).phone_number)
    assert_response :redirect
    assert_redirected_to survey_login_path(surveys(:test))
  end

  test "send login code creates outgoing text message" do
    twilio_mock(TwilioResponses.create_sms)

    assert_changes surveys(:test).outgoing_text_messages, :count, 1 do
      post :send_login_code, params_for_login_code(:test, participants(:ppt1).phone_number)
    end
  end
end
