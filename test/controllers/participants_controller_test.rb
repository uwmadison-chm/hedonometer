require 'test_helper'

class ParticipantsControllerTest < ActionController::TestCase

  def good_params
    {
      :participant => {:phone_number => '(608) 555-9999'},
      :survey_id => surveys(:test)
    }
  end

  test "participant should create" do
    post :create, good_params
    assert_response :success
    assert_not_nil assigns(:participant)
    refute assigns(:participant).new_record?
  end

  test "participant should not create duplicate" do
    post :create, good_params
    assert_response :success
    post :create, good_params
    assert_response 409
  end
end
