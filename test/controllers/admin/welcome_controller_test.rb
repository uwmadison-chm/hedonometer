# -*- encoding : utf-8 -*-
require 'test_helper'

class Admin::WelcomeControllerTest < ActionController::TestCase
  def setup
    admin_login_as :nate
  end

  test "index requires login" do
    admin_logout
    get :index
    assert_response :redirect
    assert_redirected_to admin_login_path
  end

  test "index renders when logged in" do
    get :index
    assert_response :success
  end

  test "manage admins link shows if you can change admins" do
    get :index
    assert_select "#manage-admins", 1
  end

  test "manage admins link doesn't show if you can't do it" do
    admin_login_as :limited
    get :index
    assert_select "#manage-admins", 0
  end

  test "inactive users get logged out" do
    admin_login_as :deleted
    get :index
    refute admin_id_set?
    assert_redirected_to admin_login_path
  end

  test "redirecting saves destination in session" do
    admin_logout
    get :index
    assert_response :redirect
    refute_nil session[:destination]
  end

end
