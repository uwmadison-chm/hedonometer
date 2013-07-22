require 'test_helper'

class SessionControllerTest < ActionController::TestCase
  test "login renders" do
    get :new, {survey_id: surveys(:test).id}
    assert_response :success
  end

  test "logout redirects to login" do
    get :destroy, {survey_id: surveys(:test).id}
    assert_response :redirect
    assert_redirected_to survey_login_path(surveys(:test))
  end
end
