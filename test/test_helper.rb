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

  def participant_login_as(participant)
    session[:participant_id] = participant.id
  end

  def participant_logout
    session.delete :participant_id
  end

  def participant_logged_in?
    session.include? :participant_id
  end

  def twilio_mock(body, status=200)
    stub_http_request(:any, /.*@api.twilio.com/).to_return(
      body: body, status: status)
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

  def self.failed_sms
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
    "status": "failed",
    "to": "+14159352345",
    "uri": "/2010-04-01/Accounts/AC5ef872f6da5a21de157d80997a64bd33/SMS/Messages/SM90c6fc909d8504d45ecdb3a3d5b3556e.json"
}
resp
  end

  def self.get_account(status="active")
<<-resp
{
    "sid": "ACba8bc05eacf94afdae398e642c9cc32d",
    "friendly_name": "Do you like my friendly name?",
    "type": "Full",
    "status": "#{status}",
    "date_created": "Wed, 04 Aug 2010 21:37:41 +0000",
    "date_updated": "Fri, 06 Aug 2010 01:15:02 +0000",
    "auth_token": "redacted",
    "uri": "\/2010-04-01\/Accounts\/ACba8bc05eacf94afdae398e642c9cc32d.json",
    "subresource_uris": {
        "available_phone_numbers": "\/2010-04-01\/Accounts\/ACba8bc05eacf94afdae398e642c9cc32d\/AvailablePhoneNumbers.json",
        "calls": "\/2010-04-01\/Accounts\/ACba8bc05eacf94afdae398e642c9cc32d\/Calls.json",
        "conferences": "\/2010-04-01\/Accounts\/ACba8bc05eacf94afdae398e642c9cc32d\/Conferences.json",
        "incoming_phone_numbers": "\/2010-04-01\/Accounts\/ACba8bc05eacf94afdae398e642c9cc32d\/IncomingPhoneNumbers.json",
        "notifications": "\/2010-04-01\/Accounts\/ACba8bc05eacf94afdae398e642c9cc32d\/Notifications.json",
        "outgoing_caller_ids": "\/2010-04-01\/Accounts\/ACba8bc05eacf94afdae398e642c9cc32d\/OutgoingCallerIds.json",
        "recordings": "\/2010-04-01\/Accounts\/ACba8bc05eacf94afdae398e642c9cc32d\/Recordings.json",
        "sandbox": "\/2010-04-01\/Accounts\/ACba8bc05eacf94afdae398e642c9cc32d\/Sandbox.json",
        "sms_messages": "\/2010-04-01\/Accounts\/ACba8bc05eacf94afdae398e642c9cc32d\/SMS\/Messages.json",
        "transcriptions": "\/2010-04-01\/Accounts\/ACba8bc05eacf94afdae398e642c9cc32d\/Transcriptions.json"
    }
}
resp
  end

  def self.get_active_account
    get_account("active")
  end

  def self.get_closed_account
    get_account("closed")
  end

  def self.auth_failure
    "{\"code\":20003,\"message\":\"Authenticate\",\"more_info\":\"https:\\/\\/www.twilio.com\\/docs\\/errors\\/20003\",\"status\":401}"
  end

  def self.incoming_params(survey, body, from_phone)
    {
      "AccountSid"=>"ACf20086b4a32fd314cb912316f2890564",
      "Body"=>body,
      "ToZip"=>"53706",
      "FromState"=>"WI",
      "ToCity"=>"MADISON",
      "SmsSid"=>"SM36abd8535bfbb65fe01affc5aa7081ba",
      "ToState"=>"WI",
      "To"=>survey.phone_number.to_e164,
      "ToCountry"=>"US",
      "FromCountry"=>"US",
      "SmsMessageSid"=>"SM36abd8535bfbb65fe01affc5aa7081ba",
      "ApiVersion"=>"2010-04-01",
      "FromCity"=>"BARABOO",
      "SmsStatus"=>"received",
      "From"=>PhoneNumber.to_e164(from_phone),
      "FromZip"=>"53913",
      "survey_id"=>survey.id
    }
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

  def assert_no_change(obj, method)
    before = obj.send method
    yield
    after  = obj.send method
    assert_equal before, after, "Expected #{obj.class.name}##{method} to not change, changed from #{before} to #{after}"
  end

  def assert_valid(obj, message=nil)
    assert obj.valid?, (message || obj.errors.full_messages)
  end

  def refute_valid(obj, message=nil)
    refute obj.valid?, (message || "expected #{obj} to not be valid")
  end
end
