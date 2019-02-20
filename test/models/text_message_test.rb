require 'test_helper'

class TextMessageTest < ActiveSupport::TestCase
  test "outgoing message finds ppt" do
    assert_equal text_messages(:test_ppt1_outgoing_1).participant, participants(:ppt1)
  end

  test "incoming message finds ppt" do
    assert_equal text_messages(:test_ppt1_incoming_1).participant, participants(:ppt1)
  end

  test "message without match finds nil" do
    assert_nil text_messages(:test_unknown_ppt).participant
  end

  test "participant_external_key not nil for found ppt" do
    refute_nil text_messages(:test_ppt1_outgoing_1).participant_external_key
  end

  test "participant_external_key nil for missing ppt" do
    assert_nil text_messages(:test_unknown_ppt).participant_external_key
  end
end
