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
        time_zone: participant.time_zone,
        schedule_days_attributes: participant.schedule_days.map {|sd|
          {
            id: sd.id,
            date: sd.date,
            time_ranges_string: sd.time_ranges_string
          }
        }
      }
    }
  end

  test "participant should create" do
    post :create, params_for_create
    assert_response :success
    refute_nil assigns(:participant)
    p = assigns(:participant)
    assert_empty p.schedule_days
    refute assigns(:participant).new_record?, assigns(:participant).errors.full_messages
  end

  test "participant create with schedule days" do
    params = params_for_create
    params[:participant][:schedule_start_date] = Date.today.to_s
    params[:participant][:schedule_time_after_midnight] = 9.hours.to_i
    post :create, params
    assert_response :success
    p = assigns(:participant)
    refute_empty p.schedule_days
  end

  test "participant should not create duplicate" do
    post :create, params_for_create
    assert_response :success
    post :create, params_for_create
    assert_response 409
  end

  test "creating participants can send a welcome message" do
    twilio_mock(TwilioResponses.create_sms)
    params = params_for_create
    params[:participant][:send_welcome_message] = 1
    post :create, params
    assert_response :success
    assert_requested :post, /.*@api.twilio.com/
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

  test "update schedules a question" do
    ppt = participants(:ppt1)
    participant_login_as ppt
    day = ppt.schedule_days.order('date').first
    assert_equal 0, day.scheduled_questions.count
    assert_changes day.scheduled_questions, :count, 1 do
      post :update, params_for_update(ppt)
      assert_redirected_to survey_path(ppt.survey)
    end
  end

  test "two updates don't add more questions" do
    ppt = participants(:ppt1)
    participant_login_as ppt
    day = ppt.schedule_days.order('date').first
    post :update, params_for_update(ppt)
    assert_redirected_to survey_path(ppt.survey)
    assert_equal 1, day.scheduled_questions.count
    assert_no_change day.scheduled_questions, :count do
      post :update, params_for_update(ppt)
    end
  end
end
