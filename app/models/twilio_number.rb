require 'twilio-ruby'

class TwilioNumber < ActiveRecord::Base
  belongs_to :survey

  validates :account_sid, presence: true
  validates :auth_token, presence: true
  validates :phone_number, presence: true, uniqueness: true
  validates :phone_number_sid, presence: true, uniqueness: true

  def connect!
    @client ||= Twilio::REST::Client.new @account_sid, @auth_token
    @account = @client.account
  end

  def registered_phone_numbers
    connect!
    @account.incoming_phone_numbers.list
  end

  def self.
end
