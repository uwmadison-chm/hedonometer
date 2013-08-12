# -*- encoding : utf-8 -*-
require 'time_range'

class Participant < ActiveRecord::Base
  LOGIN_CODE_LENGTH = 5

  validates :phone_number, presence: true, uniqueness: {scope: :survey_id}
  serialize :phone_number, PhoneNumber

  belongs_to :survey
  validates :survey, presence: true

  before_validation :set_login_code, on: :create
  validates :login_code, presence: true, length: {is: LOGIN_CODE_LENGTH}
  has_many :schedule_days
  accepts_nested_attributes_for :schedule_days

  def schedule_empty?
    self.schedule_days.empty?
  end

  def build_schedule_days
    start_date = Time.zone.now.to_date
    self.survey.sampled_days.times do |t|
      sample_date = start_date + t + 1
      # TODO make this not shitty
      time_range = TimeRange.new(start_date + 9.hours, start_date + 9.hours + survey.day_length_minutes.minutes)
      self.schedule_days.build date: sample_date, time_ranges: [time_range]
    end
  end

  class << self
    def authenticate(phone_number, login_code)
      Participant.where(phone_number: PhoneNumber.to_e164(phone_number), login_code: login_code).first
    end
  end

  protected
  def set_login_code
    ## All numeric, with LOGIN_CODE_LENGTH digits
    self.login_code = rand(10**LOGIN_CODE_LENGTH).to_s.rjust(LOGIN_CODE_LENGTH, '0')
  end
end
