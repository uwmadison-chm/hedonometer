require 'test_helper'
require 'csv'

class Admin::ParticipantsControllerTest < ActionController::TestCase
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

  test "show renders as csv" do
    get :show, survey_id: surveys(:test), id: participants(:ppt1),
      format: :csv
    assert_response :success
    rows = CSV.parse(response.body)
    assert rows.length == (participants(:ppt1).text_messages.count + 1)
  end

end
