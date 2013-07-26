# -*- encoding : utf-8 -*-
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/mock'
require 'webmock/minitest'

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

  def twilio_mock(body)
    stub_http_request(:any, /.*@api.twilio.com/).to_return(body: body)
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
end
