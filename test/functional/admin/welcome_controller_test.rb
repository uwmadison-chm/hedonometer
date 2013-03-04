require 'test_helper'

class Admin::WelcomeControllerTest < ActionController::TestCase
  test "index requires login" do
    get :index
    assert_response :redirect
  end

end
