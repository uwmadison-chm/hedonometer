# -*- encoding : utf-8 -*-
require 'test_helper'

class PhoneNumberTest < ActiveSupport::TestCase

  test "creating with blank gives blank" do
    assert_equal "", PhoneNumber.new("").to_e164
    assert_equal "", PhoneNumber.new(nil).to_e164
    assert PhoneNumber.new(nil).blank?
  end

  test "equality" do
    desired = "+16085551212"
    assert_equal PhoneNumber.new(desired), PhoneNumber.new(desired)
    assert_equal PhoneNumber.new(desired), desired
    assert_equal PhoneNumber.new(desired), desired[2..-1] # 6085551212
  end

  test "formats to E.164" do
    desired = "+16085551212"
    assert_equal desired, PhoneNumber.new("608-555-1212").to_e164
    assert_equal desired, PhoneNumber.new("6085551212").to_e164
    assert_equal desired, PhoneNumber.new("(608) 555-1212").to_e164
  end

  test "formats to human" do
    desired = "(608) 555-1212"
    assert_equal desired, PhoneNumber.new("608-555-1212").to_human
  end

  test "human stays in e164 format for funny numbers" do
    desired = "+1608555121"
    assert_equal desired, PhoneNumber.new("608-555-121").to_human
  end

  test "deserialization loads" do
    pn = PhoneNumber.load("6085551212")
    assert_equal pn.class, PhoneNumber
  end

  test "deserialization dumps" do
    pn = PhoneNumber.new("+16085551212")
    assert_equal PhoneNumber.dump(pn), pn.to_e164
  end
end
