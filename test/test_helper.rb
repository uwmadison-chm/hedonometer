# -*- encoding : utf-8 -*-
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/mock'

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

module MiniTest::Assertions
  def assert_changes(obj, method, exp_diff)
    before = obj.send method
    yield
    after  = obj.send method
    diff = after - before

    assert_equal exp_diff, diff, "Expected #{obj.class.name}##{method} to change by #{exp_diff}, changed by #{diff}"
  end

  def assert_method_chain(recordy, method_array)
    # for example, assert_method_chain(client, [:account, :sms: :messages, :create])
    assert method_chain_contains(recordy, method_array), "Expected method chain #{method_array.join('.')}"
  end

  def method_chain_contains(recordy, method_array)
    cur_method, *rest = *method_array
    return true if cur_method.nil?
    call = recordy.__calls.detect {|call| call[:method].to_s == cur_method.to_s}
    call && method_chain_contains(call[:return_value], rest)
  end
end

class Recordy
  attr_accessor :__calls
  def initialize
    @__calls = []
  end

  def method_missing(method, *args)
    return_value = self.class.new
    @__calls << {
      method: method,
      args: args,
      block_given: block_given?,
      return_value: return_value
    }
    yield if block_given?
    return_value
  end
end

