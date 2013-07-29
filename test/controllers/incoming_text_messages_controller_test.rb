require 'test_helper'

class IncomingTextMessagesControllerTest < ActionController::TestCase

  test "it creates a text message" do
    assert_changes surveys(:test).incoming_text_messages, :count, 1 do
      post :create, TwilioResponses.incoming_params(surveys(:test), "frabozz")
    end
  end

end
