# -*- encoding : utf-8 -*-
require 'csv'

class Survey < ApplicationRecord
  attr_accessor :creator

  has_many :survey_permissions
  has_many :admins, through: :survey_permissions
  has_one :twilio_number

  has_many :participants

  validates :name, presence: true
  validates :welcome_message, presence: true
  
  validates :creator, on: :create, presence: true
  after_create :assign_creator_as_admin

  serialize :phone_number, PhoneNumber

  has_many :outgoing_text_messages
  has_many :incoming_text_messages
  has_many :text_messages

  attr_reader :twilio_errors
  after_initialize :clear_twilio_errors
  after_initialize :fix_configuration_errors



  def schedule_participant! p
    raise "Abstract surveys can't schedule participants"
  end
  

  # These properties used to be directly on survey,
  # and it was too much work to refactor everything that referenced them.
  # So for now these are shortcuts

  def sampled_days
    configuration['sampled_days'] || 1
  end

  def sampled_days= x
    configuration['sampled_days'] = x.to_i
  end
  
  def samples_per_day
    configuration['samples_per_day'] || 4
  end

  def samples_per_day= x
    configuration['samples_per_day'] = x.to_i
  end
  
  def mean_minutes_between_samples
    configuration['mean_minutes_between_samples'] || 60
  end

  def mean_minutes_between_samples= x
    configuration['mean_minutes_between_samples'] = x.to_i
  end
  
  def sample_minutes_plusminus
    configuration['sample_minutes_plusminus'] || 15
  end

  def sample_minutes_plusminus= x
    configuration['sample_minutes_plusminus'] = x.to_i
  end

  def url
    configuration['url']
  end

  def url= x
    configuration['url'] = x
  end



  def twilio_client
    Twilio::REST::Client.new self.twilio_account_sid, self.twilio_auth_token
  end

  def day_length_minutes
    samples_per_day * mean_minutes_between_samples + sample_minutes_plusminus
  end

  def day_length
    day_length_minutes.minutes
  end

  def mininum_intersample_period
    (mean_minutes_between_samples - sample_minutes_plusminus).minutes
  end

  def maximum_intersample_period
    (mean_minutes_between_samples + sample_minutes_plusminus).minutes
  end

  def has_twilio_credentials?
    val = self.twilio_account_sid.present? and self.twilio_auth_token.present?
    logger.debug("Has twilio credentials: #{val}")
    val
  end

  def changed_phone_number?
    logger.debug("Changed phone number: #{previous_changes.include? :phone_number}")
    previous_changes.include? :phone_number
  end

  def set_twilio_number_handlers!(sms_handler_url)
    return unless has_twilio_credentials? and changed_phone_number?
    old_number, new_number = previous_changes[:phone_number]
    begin
      TwilioIncomingNumber.deactivate_sms_handler!(
        self.twilio_account_sid,
        self.twilio_auth_token,
        old_number)
    rescue Exception => exc
      logger.debug("Exception in deactivate: #{exc.inspect}")
      @twilio_errors.append("Error deactivating SMS handler for #{old_number}: #{exc.message}")
    end

    begin
      TwilioIncomingNumber.activate_sms_handler!(
        self.twilio_account_sid,
        self.twilio_auth_token,
        new_number,
        sms_handler_url)
    rescue Exception => exc
      logger.debug("Exception in activate: #{exc.inspect}")
      @twilio_errors.append("Error activating SMS handler for #{new_number}: #{exc.message}. Should be #{sms_handler_url}.")
    end
  end

  private def assign_creator_as_admin
    self.survey_permissions.create admin: creator, can_modify_survey: true
  end

  private def clear_twilio_errors
    @twilio_errors = []
  end

  private def fix_configuration_errors
    # There's a weird bug where sometimes it gets set to this weird escaped JSON nightmare thing
    if @configuration.is_a? String
      @configuration = {}
    end
    @configuration ||= {}
  end
end
