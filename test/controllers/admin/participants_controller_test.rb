require 'test_helper'

class Admin::ParticipantsControllerTest < ActionController::TestCase
  def setup
    admin_login_as :nate
    super
  end

  test "index requires login" do
    admin_logout
    get :index, survey_id:(surveys(:test))
    assert_response :redirect
  end

  test "index renders" do
    get :index, survey_id:(surveys(:test))
    assert_response :success
  end

end
