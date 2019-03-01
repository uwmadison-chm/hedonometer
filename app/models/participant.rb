# -*- encoding : utf-8 -*-
require 'time_range'

class Participant < ApplicationRecord
  LOGIN_CODE_LENGTH = 5

  validates :phone_number, presence: true, uniqueness: {scope: :survey_id}
  serialize :phone_number, PhoneNumber

  belongs_to :survey
  validates :survey, presence: true

  before_validation :set_login_code, on: :create
  validates :login_code, presence: true, length: {is: LOGIN_CODE_LENGTH}

  validates :time_zone, presence: true
  before_validation :copy_time_zone_from_survey, on: :create

  before_validation :set_requests_new_schedule, on: :create
  validate :valid_schedule_start, if: :requests_new_schedule?

  after_save :build_schedule_and_schedule_first_question_if_possible!, if: :requests_new_schedule?

  has_many :schedule_days, -> { order('participant_local_date') }, {dependent: :destroy} do
    def potential_run_targets
      where(aasm_state: ['waiting', 'running']).order('participant_local_date')
    end

    def first_potential
      potential_run_targets.first
    end

    def advance_to_day_with_time_for_message!
      potential_run_targets.each do |day|
        logger.debug("Checking day #{day.participant_local_date}")
        logger.debug("Starting status: #{day.aasm_state}")
        day.run! if day.waiting?
        day.finish! if not day.has_time_for_another_question?
        logger.debug("Final status: #{day.aasm_state}")
        return day if day.running?
      end
      nil
    end
  end
  accepts_nested_attributes_for :schedule_days

  has_many :text_messages, ->(p) {
    where('from_number=? or to_number=?', p.phone_number.to_s, p.phone_number.to_s)
    .order('delivered_at DESC')},
    through: :survey

  # Used to create schedule_days and stuff.
  attr_accessor :schedule_start_date
  attr_accessor :schedule_time_after_midnight
  attr_accessor :schedule_human_time_after_midnight
  attr_accessor :requests_new_schedule
  attr_accessor :send_welcome_message

  def set_requests_new_schedule
    @requests_new_schedule = true
  end

  def requests_new_schedule?
    @requests_new_schedule
  end

  def schedule_human_time_after_midnight=(time_string)
    return if time_string.blank?

    @schedule_human_time_after_midnight = time_string
    logger.debug("Parsing time string #{time_string}")
    begin
      self.schedule_time_after_midnight = Time.parse(time_string).seconds_since_midnight
      logger.debug("Setting schedule_time_after_midnight to #{self.schedule_time_after_midnight}")
    rescue ArgumentError => e
      logger.debug(e.to_s)
    end
  end

  def build_schedule_and_schedule_first_question_if_possible!
    if self.can_schedule_days?
      logger.debug("Setting schedule, generating first question")
      self.rebuild_schedule_days!
      logger.debug("After rebuilding schedule, we have #{self.schedule_days.count} days")
      message = self.survey.schedule_participant! self
      if message
        logger.debug("Scheduled #{message.inspect}")
        ParticipantTexter.delay(run_at: message.scheduled_at).deliver_scheduled_message!(message.id)
      else
        logger.warn("Could not schedule a question for participant #{self.id}")
      end
    else
      logger.debug("Not setting schedule.")
    end
  end

  def send_welcome_message_if_requested!
    if self.send_welcome_message?
      logger.debug("Sending welcome message: #{self.send_welcome_message}")
      message = ParticipantTexter.welcome_message(self)
      message.deliver_and_save!
    else
      logger.debug("Not sending welcome message: #{self.send_welcome_message}")
    end
  end

  def send_welcome_message?
    self.send_welcome_message.to_s == "1"
  end

  def schedule_empty?
    self.schedule_days.empty?
  end

  def build_schedule_days(start_date, time_after_midnight)
    offset = Time.use_zone(self.time_zone) do
      Time.zone.utc_offset / 1.hour
    end
    utc_start = start_date - offset.hours
    self.survey.sampled_days.times do |t|
      sample_date = utc_start + t.days
      first = sample_date + time_after_midnight
      last = first + survey.day_length
      self.schedule_days.build(
        participant_local_date: sample_date,
        time_ranges: [TimeRange.new(first, last)]
      )
    end
  end

  def has_delivered_a_question?
    sd = self.schedule_days.first
    sd and sd.scheduled_messages.delivered.first
  end

  def schedule_start_date=(d)
    Time.use_zone(self.time_zone) do
      @schedule_start_date = Date.parse(d.to_s) rescue nil
    end
  end

  def schedule_time_after_midnight=(sec)
    @schedule_time_after_midnight = sec.to_i.seconds
  end

  def rebuild_schedule_days!
    self.schedule_days.destroy_all
    self.build_schedule_days(self.schedule_start_date.to_datetime, self.schedule_time_after_midnight)
    self.schedule_days.each do |sd|
      sd.save
    end
  end

  def can_schedule_days?
    logger.debug("schedule_start_date: #{schedule_start_date}")
    logger.debug("schedule_time_after_midnight: #{schedule_time_after_midnight}")
    logger.debug("has_delivered_a_question?: #{has_delivered_a_question?}")

    # We can do this if we have a start date and time and we haven't yet
    # delvered any scheduled_questions
    self.schedule_start_date and
      self.schedule_time_after_midnight and not has_delivered_a_question?
  end

  class << self
    def authenticate(phone_number, login_code)
      Participant.where(phone_number: PhoneNumber.to_e164(phone_number), login_code: login_code).first
    end
  end

  def set_login_code
    ## All numeric, with LOGIN_CODE_LENGTH digits
    self.login_code = rand(10**LOGIN_CODE_LENGTH).to_s.rjust(LOGIN_CODE_LENGTH, '0')
  end

   def copy_time_zone_from_survey
     self.time_zone ||= survey.time_zone
   end

   def valid_schedule_start
    errors.add(:schedule_start_date, "must be a valid date") if schedule_start_date.nil?
    errors.add(:schedule_time_after_midnight, "must be a valid time") if schedule_time_after_midnight.nil?
   end
end
