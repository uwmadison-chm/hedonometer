require 'test_helper'

class Admin::AdminsControllerTest < ActionController::TestCase
  def setup
    admin_login_as :nate
  end

  test "requires login" do
    admin_logout
    get :new
    assert_response :redirect
  end

  test "requires ability to change admins" do
    admin_login_as :limited
    get :new
    assert_response :redirect
  end

  test "new works when logged in" do
    get :new
    assert_response :success
  end

  test "create works" do
    assert_changes Admin, :count, 1 do
      post :create, {admin: {email: "new@example.com", password: "testit"}}
      assert_response :redirect
    end
  end

  test "edit renders" do
    get :edit, id: admins(:nate)
  end

  test "update changes things" do
    new_email = 'nate@example.com'
    admin = admins(:nate)
    post :update, {
      id: admin,
      admin: {
        email: new_email
      }
    }
    assert_response :redirect
    assert_not_empty flash.notice
    admin.reload
    assert_equal new_email, admin.email
    assert admin.active?
  end

  test "update can deactivate" do
    admin = admins(:nate)
    post :update, {
      id: admin,
      admin: {
        active: 0
      }
    }
    admin.reload
    refute admin.active?
  end

  test "update can activate" do
    admin = admins(:deleted)
    post :update, {
      id: admin,
      admin: {
        active: 1
      }
    }
    admin.reload
    assert admin.active?
  end
end
