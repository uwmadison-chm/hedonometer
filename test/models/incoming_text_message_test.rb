require 'test_helper'

class IncomingTextMessageTest < ActiveSupport::TestCase

  test "validation sets delivered_at" do
    tm = surveys(:test).incoming_text_messages.build
    tm.valid?
    refute_nil tm.delivered_at
  end

  test "survey phone number must match To: number" do
    tm = surveys(:test).incoming_text_messages.build(
      to: surveys(:test).phone_number,
      from: '+16085559999',
      message: "test"
    )
    assert_valid tm
    tm.to = PhoneNumber.new("+16665551212")
    refute_valid tm
  end

end