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
    assert_equal 3, number_groups[:unavailable].length
    assert_equal 1, number_groups[:available].length
  end

end