require 'twilio-ruby'

# This is kind of a terrible class.

class TwilioIncomingNumber
  MAX_NUMBERS = 1000  # ought to be enough for anyone
  @@client = nil

  class << self
    def client
      @@client
    end

    def setup_client(account_sid, auth_token)
      @@client = Twilio::REST::Client.new account_sid, auth_token
    end

    def set_sms_handler!(account_sid, auth_token, number, handler_url)
      # number is presumed to be in e.164 format
      return unless number.present?
      setup_client(account_sid, auth_token)
      account = @@client.account
      i_num = account.incoming_phone_numbers.list(phone_number: number).first
      if i_num.nil?
        raise OperationFailed.new("Couldn't find number matching #{number}")
      end
      i_num.update sms_url: handler_url, sms_method: "POST"
    end

    def deactivate_sms_handler!(account_sid, auth_token, number)
      set_sms_handler!(account_sid, auth_token, number, nil)
    end

    def activate_sms_handler!(account_sid, auth_token, number, handler_url)
      set_sms_handler!(account_sid, auth_token, number, handler_url)
    end

    def list_numbers(account_sid, auth_token)
      setup_client(account_sid, auth_token)
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

  class OperationFailed < Exception
  end
end