# -*- encoding : utf-8 -*-
require 'csv'

class Survey < ActiveRecord::Base
  attr_accessor :creator

  has_many :survey_permissions
  has_many :admins, through: :survey_permissions
  has_one :twilio_number

  has_many :survey_questions
  accepts_nested_attributes_for :survey_questions,
    allow_destroy: true,
    reject_if: ->(attributes) { attributes[:question_text].blank? }


  has_many :participants

  validates :name, presence: true
  validates :samples_per_day, numericality: {only_integer: true, greater_than: 0}
  validates :mean_minutes_between_samples, numericality: {only_integer: true, greater_than: 0}
  validates :sample_minutes_plusminus, numericality: {only_integer: true, greater_than: 0}
  validates :welcome_message, presence: true

  validates :creator, on: :create, presence: true
  after_create :assign_creator_as_admin

  serialize :phone_number, PhoneNumber

  has_many :outgoing_text_messages
  has_many :incoming_text_messages
  has_many :text_messages

  attr_reader :twilio_errors
  after_initialize :clear_twilio_errors

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

  def question_chooser
    RandomNoReplacementRecordChooser
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

  private
  def assign_creator_as_admin
    self.survey_permissions.create admin: creator, can_modify_survey: true
  end

  def clear_twilio_errors
    @twilio_errors = []
  end
end
