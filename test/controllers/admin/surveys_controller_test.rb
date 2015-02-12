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
          active: true
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
    get :edit, id:surveys(:test)
    assert_response :success
    assert assigns(:survey)
  end

  test "should not make form for orphaned survey" do
    get :edit, id:surveys(:orphaned)
    assert_response :success
    assert_nil assigns(:survey)
  end

  test "should not make form for noneditable survey" do
    get :edit, id:surveys(:someone_elses)
    assert_response :success
    assert_nil assigns(:survey)
  end

  test "create a survey" do
    assert_difference 'Survey.count' do
      post :create, sample_data
    end
    s = assigns(:survey)
    assert s
    assert_redirected_to edit_admin_survey_path(s)
  end

  test "failed survey creation renders new" do
    d = sample_data
    d[:survey][:name] = ''
    post :create, d
    assert assigns(:survey).new_record?
    assert_template :new
  end

  test "update a survey" do
    s = surveys(:test)
    params = params_for_update(s)
    params[:name] = "freeow"
    post :update, id: s, survey: params
    assert assigns(:survey)
    assert_equal params[:name], assigns(:survey).name
    assert_redirected_to edit_admin_survey_path(s)
  end

  test "bad update sends to edit" do
    s = surveys(:test)
    post :update, id: s, survey: {name: ""}
    assert_response :success
    assert_template :edit
  end

  test "data downloads" do
    s = surveys(:test)
    get :show, id: s, format: 'csv'
    assert_response :success
    lines = CSV.parse(response.body)
    assert_equal lines.length, (s.text_messages.count + 1)
  end

end
