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
    twilio_mock_multi([{status: status, body: body}])
  end

  def twilio_mock_multi(option_hashes)
    stub_http_request(:any, /.*@api.twilio.com/).to_return(option_hashes)
  end

  def used_numbers
    Survey.all.select(:phone_number).map {|s| s.phone_number }
  end

  def numbers_with_extra
    used_numbers + ["+16085551212"]
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

  def self.auth_failure
    "{\"code\":20003,\"message\":\"Authenticate\",\"more_info\":\"https:\\/\\/www.twilio.com\\/docs\\/errors\\/20003\",\"status\":401}"
  end

  def self.incoming_phone_numbers(number_list)
    first = <<-resp
{
    "page": 0,
    "num_pages": 1,
    "page_size": 50,
    "total": 6,
    "start": 0,
    "end": 5,
    "uri": "\/2010-04-01\/Accounts\/ACdc5f1e11047ebd6fe7a55f120be3a900\/IncomingPhoneNumbers.json",
    "first_page_uri": "\/2010-04-01\/Accounts\/ACdc5f1e11047ebd6fe7a55f120be3a900\/IncomingPhoneNumbers.json?Page=0&PageSize=50",
    "previous_page_uri": null,
    "next_page_uri": null,
    "last_page_uri": "\/2010-04-01\/Accounts\/ACdc5f1e11047ebd6fe7a55f120be3a900\/IncomingPhoneNumbers.json?Page=0&PageSize=50",
    "incoming_phone_numbers": [
resp
    number_jsons = number_list.map { |num|
      <<-resp
        {
            "sid": "PN3f94c94562ac88dccf16f8859a1a8b25",
            "account_sid": "ACdc5f1e11047ebd6fe7a55f120be3a900",
            "friendly_name": "Long Play",
            "phone_number": "#{num}",
            "voice_url": "http:\/\/demo.twilio.com\/docs/voice.xml",
            "voice_method": "GET",
            "voice_fallback_url": null,
            "voice_fallback_method": null,
            "voice_caller_id_lookup": null,
            "voice_application_sid": null,
            "date_created": "Thu, 13 Nov 2008 07:56:24 +0000",
            "date_updated": "Thu, 13 Nov 2008 08:45:58 +0000",
            "sms_url": null,
            "sms_method": null,
            "sms_fallback_url": null,
            "sms_fallback_method": null,
            "sms_application_sid": "AP9b2e38d8c592488c397fc871a82a74ec",
            "capabilities": {
                "voice": true,
                "sms": false,
                "mms": false
            },
            "status_callback": null,
            "status_callback_method": null,
            "api_version": "2010-04-01",
            "uri": "\/2010-04-01\/Accounts\/ACdc5f1e11047ebd6fe7a55f120be3a900\/IncomingPhoneNumbers\/PN3f94c94562ac88dccf16f8859a1a8b25.json"
        }
      resp
    }.join(",\n")
    first + number_jsons + "]\n}"
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
