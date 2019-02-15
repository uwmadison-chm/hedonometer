# -*- encoding : utf-8 -*-
require 'test_helper'
require 'csv'

class Admin::SurveysControllerTest < ActionController::TestCase
  def setup
    admin_login_as :nate
  end

  def sample_data
    {survey: {
          name: "New survey!",
          mean_minutes_between_samples: 60,
          sample_minutes_plusminus: 10,
          active: true,
          twilio_account_sid: "test",
          twilio_auth_token: "test",
          phone_number: "+16085551212",
    }}
  end

  def params_for_update(survey)
    {
      id: survey.id,
      name: survey.name,
      samples_per_day: survey.samples_per_day,
      mean_minutes_between_samples: survey.mean_minutes_between_samples,
      sample_minutes_plusminus: survey.sample_minutes_plusminus,
      time_zone: survey.time_zone,
      active: survey.active,
      twilio_account_sid: survey.twilio_account_sid,
      twilio_auth_token: survey.twilio_auth_token,
      phone_number: survey.phone_number,
      help_message: survey.help_message,
      welcome_message: survey.welcome_message
    }
  end

  test "new requires login" do
    admin_logout
    get :new
    assert_response :redirect
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit for editable survey" do
    get :edit, params: {id: surveys(:test)}
    assert_response :success
    assert assigns(:survey)
  end

  test "should not make form for orphaned survey" do
    get :edit, params: {id: surveys(:orphaned)}
    assert_response :success
    assert_nil assigns(:survey)
  end

  test "should not make form for noneditable survey" do
    get :edit, params: {id: surveys(:someone_elses)}
    assert_response :success
    assert_nil assigns(:survey)
  end

  test "create a survey" do
    num = "+16085551212"
    twilio_mock_multi(TwilioResponses.responses_for_activate(num))

    assert_difference 'Survey.count' do
      post :create, params: sample_data
    end
    s = assigns(:survey)
    assert s
    assert_redirected_to edit_admin_survey_path(s)
  end

  test "creating a survey makes API calls to twilio for setting sms url" do
    num = "+16085551212"
    twilio_mock_multi(TwilioResponses.responses_for_activate(num))
    post :create, params: sample_data
    assert_requested :get, /api.twilio.com/, times: 1
    assert_requested :post, /api.twilio.com/, times: 1
  end

  test "updating a survey makes API calls for setting and deleteing sms" do
    s = surveys(:test)
    num = "+16085551212"
    twilio_mock_multi(
      TwilioResponses.responses_for_activate(num) +
      TwilioResponses.responses_for_deactivate(num)
    )

    params = params_for_update(s)
    params[:phone_number] = num
    post :update, params: {id: s, survey: params}
    assert assigns(:survey)
    assert_equal params[:name], assigns(:survey).name
    assert_redirected_to edit_admin_survey_path(s)
    assert_requested :get, /api.twilio.com/, times: 2
    assert_requested :post, /api.twilio.com/, times: 2
  end

  test "failed survey creation renders new" do
    d = sample_data
    d[:survey][:name] = ''
    post :create, params: d
    assert assigns(:survey).new_record?
    assert_template :new
  end

  test "update a survey" do
    s = surveys(:test)
    params = params_for_update(s)
    params[:name] = "freeow"
    post :update, params: {id: s, survey: params}
    assert assigns(:survey)
    assert_equal params[:name], assigns(:survey).name
    assert_redirected_to edit_admin_survey_path(s)
    # Also we should not hit Twilio's API
    assert_requested :get, /api.twilio.com/, times: 0
    assert_requested :post, /api.twilio.com/, times: 0
  end

  test "bad update sends to edit" do
    s = surveys(:test)
    post :update, params: {id: s, survey: {name: ""}}
    assert_response :success
    assert_template :edit
  end

  test "data downloads" do
    s = surveys(:test)
    get :show, params: {id: s, format: 'csv'}
    assert_response :success
    lines = CSV.parse(response.body)
    assert_equal lines.length, (s.text_messages.count + 1)
  end

end
