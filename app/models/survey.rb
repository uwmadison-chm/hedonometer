# -*- encoding : utf-8 -*-
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

  validates :creator, on: :create, presence: true
  after_create :assign_creator_as_admin

  serialize :phone_number, PhoneNumber

  has_many :outgoing_text_messages
  has_many :incoming_text_messages

  def twilio_client
    cli = Twilio::REST::Client.new self.twilio_account_sid, self.twilio_auth_token
  end

  def day_length_minutes
    samples_per_day * mean_minutes_between_samples + sample_minutes_plusminus
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

  private
  def assign_creator_as_admin
    self.survey_permissions.create admin: creator, can_modify_survey: true
  end
end
