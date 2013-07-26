require 'test_helper'

class OutgoingTextMessageTest < ActiveSupport::TestCase

  test "deliver sets stuff" do
    twilio_mock(TwilioResponses.create_sms)
    otm = surveys(:test).outgoing_text_messages.build(
      to: '+16085551212',
      from: '+16085559999',
      message: 'bogus')
    otm.deliver!
    refute_nil otm.scheduled_at
    refute_nil otm.delivered_at
    assert_kind_of Hash, otm.server_response
  end

  test "deliver raises exeception on failure" do
    twilio_mock(TwilioResponses.failed_sms)
    otm = surveys(:test).outgoing_text_messages.build(
      to: '+16085551212',
      from: '+16085559999',
      message: 'bogus')
    assert_raises TextMessage::DeliveryError do
      otm.deliver!
    end
  end
end
