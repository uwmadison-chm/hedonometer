require 'test_helper'

class Admin::SessionsControllerTest < ActionController::TestCase
  test "should get new without login" do
    get :new
    assert_response :success
  end
  
  test "new clears session" do
    admin_login_as :nate
    get :new
    assert !admin_id_set?
  end

end
