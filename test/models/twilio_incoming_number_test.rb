# -*- encoding : utf-8 -*-
require 'test_helper'

class TwilioIncomingNumberTest < ActiveSupport::TestCase
  def teardown
    WebMock.reset!
    super
  end

  test "numbers get all listed" do
    twilio_mock(TwilioResponses.incoming_phone_numbers(
      ["+16085551212", "+16085551213"]))
    numbers = TwilioIncomingNumber.list_numbers("test", "test")
    assert_equal 2, numbers.length
  end

  test "numbers partition into available and unavailable" do
    twilio_mock(TwilioResponses.incoming_phone_numbers(numbers_with_extra))
    number_groups = TwilioIncomingNumber.available_unavailable_numbers(
      "test", "test")
    assert_equal 5, number_groups[:unavailable].length
    assert_equal 1, number_groups[:available].length
  end

  test "deactivate makes API calls" do
    num = "+16085551212"
    twilio_mock_multi(TwilioResponses.responses_for_deactivate(num))
    TwilioIncomingNumber.deactivate_sms_handler!("test", "test", num)
    assert_requested :get, /api.twilio.com/, times: 1
    assert_requested :post, /api.twilio.com/, times: 1
  end

  test "activate makes API calls" do
    num = "+16085551212"
    twilio_mock_multi(TwilioResponses.responses_for_activate(num))
    TwilioIncomingNumber.activate_sms_handler!(
      "test", "test", num, "http://www.google.com")
    assert_requested :get, /api.twilio.com/, times: 1
    assert_requested :post, /api.twilio.com/, times: 1
  end

end
