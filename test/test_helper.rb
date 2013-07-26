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

module TwilioResponses
  def self.create_sms
<<-resp
{
    "account_sid": "AC5ef872f6da5a21de157d80997a64bd33",
    "api_version": "2010-04-01",
    "body": "Jenny please?! I love you <3",
    "date_created": "Wed, 18 Aug 2010 20:01:40 +0000",
    "date_sent": null,
    "date_updated": "Wed, 18 Aug 2010 20:01:40 +0000",
    "direction": "outbound-api",
    "from": "+14158141829",
    "price": null,
    "sid": "SM90c6fc909d8504d45ecdb3a3d5b3556e",
    "status": "queued",
    "to": "+14159352345",
    "uri": "/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages/SM90c6fc909d8504d45ecdb3a3d5b3556e.json"
}
resp
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
