require 'test_helper'
require 'csv'

class Admin::ParticipantsControllerTest < ActionController::TestCase
  def params_for_update(participant)
    {
      survey_id: participant.survey,
      id: participant,
      participant: {
        phone_number: "(608) 555-1234",
        participant_key: "test",
        active: "1"
      }
    }
  end

  def params_for_create(survey)
    {
      participant: {
        phone_number: '(608) 555-9999',
        schedule_start_date: '2014-01-01',
        schedule_human_time_after_midnight: '8:00'

      },
      survey_id: survey
    }
  end


  def setup
    admin_login_as :nate
    super
  end

  test "index requires login" do
    admin_logout
    get :index, params: {survey_id: surveys(:test)}
    assert_response :redirect
  end

  test "index renders" do
    get :index, params: {survey_id: surveys(:test)}
    assert_response :success
  end

  test "show renders" do
    get :show, params: {survey_id: surveys(:test), id: participants(:ppt1)}
    assert_response :success
  end

  test "show renders as csv" do
    get :show, params: {survey_id: surveys(:test), id: participants(:ppt1),
      format: :csv}
    assert_response :success
    rows = CSV.parse(response.body)
    assert rows.length == (participants(:ppt1).text_messages.count + 1)
  end

  test "edit renders" do
    get :edit, params: {survey_id: surveys(:test), id: participants(:ppt1)}
    assert_response :success
  end

  test "creating schedules days and message" do
    post :create, params: params_for_create(surveys(:test))
    ppt = assigns(:participant)
    assert_empty ppt.errors
    assert_redirected_to admin_survey_participants_path(surveys(:test))
    refute_empty ppt.schedule_days
    refute_nil ppt.schedule_days.first.scheduled_questions
  end

  test "update participant" do
    params = params_for_update(participants(:ppt1))
    put :update, params: params
    assert_redirected_to edit_admin_survey_participant_path(
      surveys(:test), participants(:ppt1))
    assert_equal assigns(:participant).phone_number.humanize, params[:participant][:phone_number]
  end

  test "participant time zone affects start time" do
    params = params_for_create(surveys(:test))
    params[:participant][:time_zone] = "Central Time (US & Canada)"
    post :create, params: params
    assert_redirected_to admin_survey_participants_path(surveys(:test))
    ppt1 = assigns(:participant)
    msg1 = ppt1.schedule_days.first.scheduled_questions.first
    params[:participant][:time_zone] = "Pacific/Honolulu"
    params[:participant][:phone_number] = "(608) 555-9998"
    post :create, params: params
    assert_redirected_to admin_survey_participants_path(surveys(:test))
    ppt2 = assigns(:participant)
    msg2 = ppt2.schedule_days.first.scheduled_questions.first

    assert_operator (msg2.scheduled_at - msg1.scheduled_at), :>, 2.hours
  end
end
