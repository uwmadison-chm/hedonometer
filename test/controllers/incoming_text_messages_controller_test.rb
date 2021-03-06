require 'test_helper'

class IncomingTextMessagesControllerTest < ActionController::TestCase

  test "it creates a text message" do
    assert_difference "surveys(:test).incoming_text_messages.count", 1 do
      post :create, params: TwilioResponses.incoming_params(surveys(:test), "frabozz", participants(:ppt1).phone_number)
    end
  end

  test "deactivates participants when we get a STOP message" do
    twilio_mock(TwilioResponses.create_sms)
    ppt = participants(:ppt1)
    post :create, params: TwilioResponses.incoming_params(surveys(:test), "stop", ppt.phone_number)
    ppt.reload
    refute ppt.active?
  end

  test "activates participants when we get a START message" do
    twilio_mock(TwilioResponses.create_sms)
    ppt = participants(:ppt1)
    ppt.active = false
    ppt.save!
    post :create, params: TwilioResponses.incoming_params(surveys(:test), "start", ppt.phone_number)
    ppt = Participant.find(ppt.id)
    assert ppt.active?, "participant should be active"
  end
end
