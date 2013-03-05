require 'test_helper'

class Admin::SessionControllerTest < ActionController::TestCase
  test "should get new without login" do
    get :new
    assert_response :success
  end
  
  test "new maintains session" do
    admin_login_as :nate
    get :new
    assert admin_id_set?
  end
  
  test "logout clears session" do
    admin_login_as :nate
    get :destroy
    assert_false admin_id_set?
  end
  
  test "destroy clears session and redirects to login" do
    admin_login_as :nate
    get :destroy
    assert_response :redirect
    assert_redirected_to admin_login_path
  end
  
end