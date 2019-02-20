# -*- encoding : utf-8 -*-
require 'test_helper'

class AdminTest < ActiveSupport::TestCase
  test "active admin scope" do
    assert_equal Admin.where(deleted_at: nil).count, Admin.active.count
  end

  test "inactive admin scope" do
    assert_equal Admin.where("deleted_at is not null").count, Admin.inactive.count
  end

  test "password checking works" do
    a = admins(:nate)
    t = Admin.authenticate(a.email, 'password')
    assert_equal a, t
  end

  test "password checking fails with bad password" do
    a = admins(:nate)
    assert_nil Admin.authenticate(a.email, 'bad_password')
  end

  test "password checking fails with no password" do
    a = admins(:deleted)
    assert_nil Admin.authenticate(a.email, '')
  end

  test "creating a user encrypts password" do
    a = Admin.create(email:'foo@example.com', password:'password')
    assert a.valid?
    refute_nil a.password_salt
    refute_nil a.password_hash
  end

  test "admins must have unique email addresses" do
    a = Admin.new(email:admins(:nate).email, password:'foo')
    refute a.valid?
  end

  test "deactivating sets deleted_at" do
    a = Admin.new
    a.active = 0
    refute a.active?
    a.active = ""
    refute a.active?
    refute_nil a.deleted_at
    a.active = 1
    assert a.active?
    a.active = ""
    assert a.active?
    assert_nil a.deleted_at
  end

  test "admins can find modifiable surveys" do
    a = admins(:nate)
    ms = a.surveys.modifiable.to_a
    assert_includes ms, surveys(:test)
    refute_includes ms, surveys(:someone_elses)
    refute_includes ms, surveys(:orphaned)
  end

  test "admins can test for modifiability" do
    a = admins(:nate)
    assert a.can_modify_survey? surveys(:test)
    refute a.can_modify_survey? surveys(:someone_elses)
    refute a.can_modify_survey? surveys(:orphaned)
  end
end
