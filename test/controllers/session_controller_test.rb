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
    {
      "participant"=>{
        "phone_number"=>phone_number,
        "login_code"=>login_code},
      "login"=>"Log me in!",
      "survey_id"=>survey.id
    }
  end

  def bad_login_params_for(participant)
    params_for_login(participant.survey, participant.phone_number, 'bogus')
  end

  def good_login_params_for(participant)
    params_for_login(participant.survey, participant.phone_number, participant.login_code)
  end

  test "login renders" do
    get :new, params: {survey_id: surveys(:test).id}
    assert_response :success
  end

  test "logout redirects to login" do
    get :destroy, params: {survey_id: surveys(:test).id}
    assert_response :redirect
    assert_redirected_to survey_login_path(surveys(:test))
  end

  test "send login code succeeds" do
    twilio_mock(TwilioResponses.create_sms)

    post :send_login_code, params: params_for_login_code(:test, participants(:ppt1).phone_number)
    assert_response :redirect
    assert_redirected_to survey_login_path(surveys(:test),
      {participant: {phone_number: participants(:ppt1).phone_number.to_s}})
  end

  test "failed login renders new" do
    post :create, params: bad_login_params_for(participants(:ppt1))
    assert_response :success
    assert_template :new
  end

  test "good login redirects to survey path" do
    post :create, params: good_login_params_for(participants(:ppt1))
    assert_response :redirect
    assert_redirected_to survey_path(participants(:ppt1).survey)
  end

  test "good login sets participant_id in session" do
    post :create, params: good_login_params_for(participants(:ppt1))
    assert_includes session, :participant_id
  end

  test "send login code creates outgoing text message" do
    twilio_mock(TwilioResponses.create_sms)

    assert_difference "surveys(:test).outgoing_text_messages.count", 1 do
      post :send_login_code, params: params_for_login_code(:test, participants(:ppt1).phone_number)
    end
  end
end
