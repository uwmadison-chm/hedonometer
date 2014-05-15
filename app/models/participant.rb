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

  validates :time_zone, presence: true
  before_validation :copy_time_zone_from_survey, on: :create

  has_many :schedule_days, {dependent: :destroy}, -> { order('date') } do
    def potential_run_targets
      where(aasm_state: ['waiting', 'running']).order('date')
    end

    def first_potential
      potential_run_targets.first
    end

    def advance_to_day_with_time_for_question!
      potential_run_targets.each do |day|
        day.run! if day.waiting?
        day.finish! if not day.has_time_for_another_question?
        return day if day.running?
      end
      nil
    end
  end
  accepts_nested_attributes_for :schedule_days

  has_many :text_messages, ->(p) {
    where('`from`=? or `to`=?', p.phone_number.to_s, p.phone_number.to_s)
    .order('delivered_at DESC')},
    through: :survey

  serialize :question_chooser_state

  # Used to create schedule_days and stuff.
  attr_accessor :schedule_start_date
  attr_accessor :schedule_time_after_midnight
  attr_accessor :schedule_human_time_after_midnight
  attr_accessor :send_welcome_message

  def schedule_human_time_after_midnight=(time_string)
    return if time_string.blank?
    @schedule_human_time_after_midnight = time_string
    logger.debug("Parsing time string #{time_string}")
    begin
      self.schedule_time_after_midnight = Time.parse(time_string).
        seconds_since_midnight
      logger.debug("Setting schedule_time_after_midnight to #{self.schedule_time_after_midnight}")
    rescue ArgumentError => e
      logger.debug(e.to_s)
    end
  end

  def build_schedule_and_schedule_first_question_if_possible!
    if self.can_schedule_days?
      Time.zone = self.time_zone
      logger.debug("Setting schedule, generating first question!")
      self.rebuild_schedule_days!
      q = self.schedule_survey_question_and_save!
      if q
        logger.debug("Scheduled #{q.inspect}")
        ParticipantTexter.delay(run_at: q.scheduled_at).deliver_scheduled_question!(q.id)
      else
        logger.warn("Could not schedule a question for #{@participant}")
      end
    else
      logger.debug("Not setting schedule.")
    end
  end

  def send_welcome_message_if_requested!
    if self.send_welcome_message
      logger.debug("Sending welcome message: #{self.send_welcome_message}")
      message = ParticipantTexter.welcome_message(self)
      message.deliver_and_save!
    else
      logger.debug("Not sending welcome message: #{self.send_welcome_message}")
    end
  end

  def schedule_empty?
    self.schedule_days.empty?
  end

  def build_schedule_days(start_date, time_after_midnight)
    self.survey.sampled_days.times do |t|
      sample_date = start_date + t.days
      first = sample_date + time_after_midnight
      last = first + survey.day_length
      self.schedule_days.build(
        date: sample_date, time_ranges: [TimeRange.new(first, last)])
    end
  end

  def choose_question
    chooser = survey.question_chooser.from_serializer(survey.survey_questions, question_chooser_state)
    chooser.choose.tap {
      self.question_chooser_state = chooser.serialize_state
      logger.debug("New question chooser state: #{self.question_chooser_state}")
    }
  end

  def current_question_or_new
    # Returns a question or new -- unsaved.
    day = schedule_days.advance_to_day_with_time_for_question!
    logger.debug("Day is #{day}")
    return nil unless day
    question = day.current_question
    if question.nil?
      survey_question = choose_question
      question = day.scheduled_questions.build(
        survey_question: survey_question)
    end
    question
  end

  def schedule_survey_question
    # Returns a scheduled_question or nil. Question is not saved. Participant is not saved -- though
    # question_chooser_state may be updated.
    question = current_question_or_new
    return nil unless question
    # We know question is not delivered; we can set its scheduled_at
    question.scheduled_at = question.schedule_day.random_time_for_next_question
    logger.debug("Scheduled #{question}")
    question
  end

  def schedule_survey_question_and_save!
    q = schedule_survey_question
    q.save!
    self.save! # Because we've updated our chooser state
    q
  end

  def has_delivered_a_question?
    sd = self.schedule_days.first
    sd and sd.scheduled_questions.delivered.first
  end

  def schedule_start_date=(d)
    @schedule_start_date = Date.parse(d.to_s) rescue nil
  end

  def schedule_time_after_midnight=(sec)
    @schedule_time_after_midnight = sec.to_i.seconds
  end

  def rebuild_schedule_days!
    self.schedule_days.destroy_all
    self.build_schedule_days(self.schedule_start_date, self.schedule_time_after_midnight)
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

  protected
  def set_login_code
    ## All numeric, with LOGIN_CODE_LENGTH digits
    self.login_code = rand(10**LOGIN_CODE_LENGTH).to_s.rjust(LOGIN_CODE_LENGTH, '0')
  end

   def copy_time_zone_from_survey
     self.time_zone = survey.time_zone
   end
end
