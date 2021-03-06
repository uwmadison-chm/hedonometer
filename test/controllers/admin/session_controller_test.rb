# -*- encoding : utf-8 -*-
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
    refute admin_id_set?
  end

  test "destroy clears session and redirects to login" do
    admin_login_as :nate
    get :destroy
    assert_response :redirect
    assert_redirected_to admin_login_path
  end

  test "login with good password sets admin_id" do
    refute admin_id_set?
    post :create, params: {email: admins(:nate).email, password: 'password'}
    assert admin_id_set?
  end

  test "login with good password works" do
    post :create,
      params: {email: admins(:nate).email, password: 'password'},
      session: {destination: 'foo'}
    assert_response :redirect
    assert_redirected_to 'foo'
  end

  test "default redirect to root url" do
    post :create, params: {email: admins(:nate).email, password: 'password'}
    assert_redirected_to admin_root_url
  end

  test "bad password renders new" do
    post :create, params: {email: admins(:nate).email, password: 'bad'}
    assert_response :success
    assert_template :new
  end

  test "no params on login renders new" do
    post :create
    assert_response :success
    assert_template :new
  end

end
