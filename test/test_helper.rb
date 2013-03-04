ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def admin_login_as(fixture_name)
    session[:admin_id] = admins(fixture_name).id
  end

  def admin_logout
    session.delete :admin_id
  end
  
  def admin_id_set?
    session.include? :admin_id
  end

  # Add more helper methods to be used by all tests here...
end
