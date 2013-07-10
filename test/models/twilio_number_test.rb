require 'test_helper'
require 'twilio-ruby'
require 'minitest/mock'

class TwilioNumberTest < ActiveSupport::TestCase
  def mock_twilio_service(stub_client)
    Twilio::REST::Client.stub :new, stub_client do
      yield
    end
  end

  test "basic client mocks" do
    test_string = "I am a kitten"
    client = MiniTest::Mock.new
    client.expect(:mock_method, test_string)
    mock_twilio_service(client) do
      a = Twilio::REST::Client.new
      assert_equal a.mock_method, test_string
    end
  end

  test "lists phone numbers" do
    # TODO: Obviously we'll need to make this simpler to use
    ipn = MiniTest::Mock.new
    ipn.expect :list, []
    a = MiniTest::Mock.new
    a.expect :incoming_phone_numbers, ipn
    cli = MiniTest::Mock.new
    cli.expect :account, a
    mock_twilio_service(cli) do
      tn = TwilioNumber.new account_sid: 'bogus', auth_token: 'bogus'
      assert_equal tn.registered_phone_numbers, []
    end

  end
end
