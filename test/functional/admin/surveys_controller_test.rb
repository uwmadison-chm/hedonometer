require 'test_helper'

class Admin::SurveysControllerTest < ActionController::TestCase
  def setup
    admin_login_as :nate
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, id:surveys(:test).id
    assert_response :success
  end
end
