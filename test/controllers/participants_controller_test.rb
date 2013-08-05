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

  def params_for_edit(survey)
    {
      survey_id: survey.id
    }
  end

  def params_for_update(participant)
    {
      survey_id: participant.survey_id,
      participant: {
      }
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

  test "edit requires login" do
    get :edit, params_for_edit(surveys(:test))
    assert_redirected_to survey_login_path()
  end

  test "edit renders" do
    participant_login_as participants(:ppt1)
    get :edit, params_for_edit(surveys(:test))
    assert_response :success
  end

  test "update succeeds" do
    ppt = participants(:ppt1)
    participant_login_as ppt
    params = params_for_update(ppt)
    params[:participant][:time_zone] = "Hawaii"
    post :update, params
    assert_equal "Hawaii", ppt.reload.time_zone
    assert_redirected_to survey_path(ppt.survey)
  end
end
