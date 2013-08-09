# -*- encoding : utf-8 -*-
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

  test "saving schedule works" do
    p = participants(:ppt1)
    p.schedule = Schedule.build_for_participant p
    p.save
    p2 = Participant.find(p.id)
    assert_equal p.survey.sampled_days, p2.schedule.days.length
  end

  test "setting schedule_days works" do
    p = participants(:ppt1)
    s = Schedule.build_for_participant p
    attrs = s.days.map {|d|
      time_range = d.time_ranges.first
      [{date: d.date.strftime("%Y-%m-%d"), time_ranges: ""}]
    }
  end

end
