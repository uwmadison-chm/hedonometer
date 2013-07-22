require 'test_helper'

class ParticipantTest < ActiveSupport::TestCase
  test "participants are generated with login codes" do
    p = surveys(:test).participants.create(phone_number: '1')
    refute p.new_record?, p.errors.full_messages
    assert_equal p.login_code.length, Participant::LOGIN_CODE_LENGTH
  end

  test "phone numbers get serialized" do
    p = surveys(:test).participants.create(phone_number: '608-555-9999')
    assert_equal PhoneNumber, p.phone_number.class
  end

  test "phone numbers load serialized" do
    assert_equal PhoneNumber, participants(:ppt1).phone_number.class
  end

  test "participant authentication works" do
    assert_nil Participant.authenticate('1', '1')
    assert_equal participants(:ppt1), Participant.authenticate('+16085551212', '12345')
    assert_equal participants(:ppt1), Participant.authenticate('6085551212', '12345')
    assert_equal participants(:ppt1), Participant.authenticate(PhoneNumber.new('6085551212'), '12345')
  end
end
