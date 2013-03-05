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
end
