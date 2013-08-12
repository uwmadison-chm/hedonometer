# -*- encoding : utf-8 -*-

# Require these so serialization works properly
require 'schedule'
require 'day'
require 'time_range'

class Participant < ActiveRecord::Base
  LOGIN_CODE_LENGTH = 5

  validates :phone_number, presence: true, uniqueness: {scope: :survey_id}
  serialize :phone_number, PhoneNumber

  belongs_to :survey
  validates :survey, presence: true

  before_validation :set_login_code, on: :create
  validates :login_code, presence: true, length: {is: LOGIN_CODE_LENGTH}

  serialize :schedule

  def schedule_days=(day_attrs)
    logger.debug(Time.zone)
    # will be an array of {date: 'XX', time_ranges: 'A:BB AM - C:DD AM, E:FF AM - G:HH PM'}
    # Gonna Just Do This.
    days = day_attrs.map {|attrs|
      day_date = Date.parse(attrs[:date])
      date_str = day_date.strftime("%Y-%m-%d")
      time_ranges = attrs[:time_ranges].split(",").map {|range|
        start_at, end_at = range.split("-").map {|part| Time.zone.parse("#{date_str} #{part}")} #hoo boy
        range = Schedule::TimeRange.new(start_at.utc, end_at.utc)
        logger.debug(range.start_at)
        range
      }
      Schedule::Day.new(day_date, time_ranges)
    }
    self.schedule = Schedule.new(days)
  end

  def schedule_days
    schedule.days
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
