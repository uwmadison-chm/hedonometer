# -*- encoding : utf-8 -*-
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
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

  def mock_twilio_service(stub_client)
    Twilio::REST::Client.stub :new, stub_client do
      yield
    end
  end

end

class Recordy
  attr_accessor :calls
  def initialize
    @calls = []
  end

  def method_missing(method, *args)
    ret = self.class.new
    @calls << {
      method: method,
      args: args,
      block_given: block_given?,
      ret: ret
    }
    yield if block_given?
    ret
  end
end
