require 'test_helper'

class Admin::WelcomeControllerTest < ActionController::TestCase
  def setup
    admin_login_as :nate
  end
  
  test "index requires login" do
    admin_logout
    get :index
    assert_response :redirect
  end
  
  test "index renders when logged in" do
    get :index
    assert_response :success
  end

end
