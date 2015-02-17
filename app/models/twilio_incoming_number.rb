require 'twilio-ruby'

class TwilioIncomingNumber
  MAX_NUMBERS = 1000  # ought to be enough for anyone
  @@client = nil

  class << self
    def list_numbers(account_sid, auth_token)
      @@client = Twilio::REST::Client.new account_sid, auth_token
      result = @@client.account.incoming_phone_numbers.list page_size: MAX_NUMBERS
      result.map { |num|
        {
          phone_number: num.phone_number,
          phone_number_human: PhoneNumber.new(num.phone_number).humanize,
          sid: num.sid,
          friendly_name: num.friendly_name,
        }
      }
    end

    def client
      @@client
    end

    def partitition_available_unavailable(number_list)
      result = number_list.partition {|num|
        Survey.exists?(phone_number: num[:phone_number])
      }
      return {
        :unavailable => result[0],
        :available => result[1]
      }
    end

    def available_unavailable_numbers(account_sid, auth_token)
      partitition_available_unavailable(list_numbers(account_sid, auth_token))
    end
  end
end