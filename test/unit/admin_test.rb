require 'test_helper'

class AdminTest < ActiveSupport::TestCase
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
    assert_not_nil a.password_salt
    assert_not_nil a.password_hash
  end
  
  test "admins must have unique email addresses" do
    a = Admin.new(email:admins(:nate).email, password:'foo')
    assert_false a.valid?
  end
end
