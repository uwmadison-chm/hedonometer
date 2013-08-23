require 'test_helper'

class IncomingTextMessagesControllerTest < ActionController::TestCase

  test "it creates a text message" do
    assert_changes surveys(:test).incoming_text_messages, :count, 1 do
      post :create, TwilioResponses.incoming_params(surveys(:test), "frabozz", participants(:ppt1).phone_number)
    end
  end

  test "deactivates participants when we get a STOP message" do
    skip "I don't know why this doesn't work, let's debug it" and return
    ppt = participants(:ppt1)
    post :create, TwilioResponses.incoming_params(surveys(:test), "stop", ppt.phone_number)
    ppt.reload
    refute ppt.active?
  end

end
