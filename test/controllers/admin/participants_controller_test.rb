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

  def setup
    admin_login_as :nate
    super
  end

  test "index requires login" do
    admin_logout
    get :index, survey_id: surveys(:test)
    assert_response :redirect
  end

  test "index renders" do
    get :index, survey_id: surveys(:test)
    assert_response :success
  end

  test "show renders" do
    get :show, survey_id: surveys(:test), id: participants(:ppt1)
    assert_response :success
  end

  test "show renders as csv" do
    get :show, survey_id: surveys(:test), id: participants(:ppt1),
      format: :csv
    assert_response :success
    rows = CSV.parse(response.body)
    assert rows.length == (participants(:ppt1).text_messages.count + 1)
  end

  test "edit renders" do
    get :edit, survey_id: surveys(:test), id: participants(:ppt1)
    assert_response :success
  end

  test "update participant" do
    params = params_for_update(participants(:ppt1))
    put :update, params
    assert_redirected_to edit_admin_survey_participant_path(
      surveys(:test), participants(:ppt1))
    assert_equal assigns(:participant).phone_number.humanize, params[:participant][:phone_number]
  end
end
