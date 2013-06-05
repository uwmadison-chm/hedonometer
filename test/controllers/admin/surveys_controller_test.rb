require 'test_helper'

class Admin::SurveysControllerTest < ActionController::TestCase
  def setup
    admin_login_as :nate
  end

  def sample_data
    {survey: {
          name: "New survey!",
          mean_minutes_between_samples: 60,
          sample_minutes_plusminus: 10,
          active: true
    }}
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

  test "create a survey" do
    post :create, sample_data
    s = assigns(:survey)
    assert s
    refute s.new_record?
    assert_redirected_to edit_admin_survey_path(s)
  end

  test "failed survey creation renders new" do
    d = sample_data
    d[:survey][:name] = ''
    post :create, d
    assert assigns(:survey).new_record?
    assert_template :new
  end
end
