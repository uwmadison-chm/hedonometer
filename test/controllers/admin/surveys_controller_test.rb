require 'test_helper'

class Admin::SurveysControllerTest < ActionController::TestCase
  def setup
    admin_login_as :nate
  end

  test "new requires login" do
    admin_logout
    get :new
    assert_response :redirect
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit for editable survey" do
    get :edit, id:surveys(:test).id
    assert_response :success
    assert assigns(:survey)
  end

  test "should not make form for orphaned survey" do
    get :edit, id:surveys(:orphaned).id
    assert_response :success
    assert_nil assigns(:survey)
  end

  test "should not make form for noneditable survey" do
    get :edit, id:surveys(:someone_elses).id
    assert_response :success
    assert_nil assigns(:survey)
  end
end
