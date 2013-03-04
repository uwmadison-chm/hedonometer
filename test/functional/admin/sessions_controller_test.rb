require 'test_helper'

class Admin::SessionsControllerTest < ActionController::TestCase
  test "should get new without login" do
    get :new
    assert_response :success
  end

end
