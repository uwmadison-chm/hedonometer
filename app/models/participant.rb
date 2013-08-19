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

  serialize :question_chooser_state

  def schedule_empty?
    self.schedule_days.empty?
  end

  def build_schedule_days
    start_date = Time.zone.now.to_date
    self.survey.sampled_days.times do |t|
      sample_date = start_date + t + 1
      # TODO replace 9.hours with a survey-level preference
      time_range = TimeRange.new(start_date + 9.hours, start_date + 9.hours + survey.day_length_minutes.minutes)
      self.schedule_days.build date: sample_date, time_ranges: [time_range]
    end
  end

  def choose_question
    chooser = survey.question_chooser.from_serializer(survey.survey_questions, question_chooser_state)
    chooser.choose.tap {
      self.question_chooser_state = chooser.serialize_state
      logger.debug("New question chooser state: chooser.serialize_state")
    }
  end

  def current_question_or_new
    # Returns a question or new -- unsaved.
    day = first_available_schedule_day
    logger.debug("Day is #{day}")
    return nil unless day
    question = day.undelivered_question
    if question.nil?
      survey_question = choose_question
      question = day.scheduled_questions.build(
        survey_question: survey_question)
    end
    question
  end

  def first_available_schedule_day
    # We could be dealing with questions from yesterday if the day ran past midnight
    # This feels so damn ugly. I'm doing this wrong.
    # TODO: Bring the number of future seconds in here
    days = self.schedule_days.potentials_for_date(Date.today)
    days.find {|day| day.can_deliver_more_questions?}
  end

  def schedule_survey_question
    # Returns a scheduled_question or nil. Question is not saved. Participant is not saved -- though
    # question_chooser_state may be updated.
    question = current_question_or_new
    # We know question is not delivered; we can set its scheduled_at
    question.scheduled_at = question.schedule_day.random_time_for_next_question
    logger.debug("Scheduled #{question}")
    question
  end

  def schedule_survey_question_and_save!
    q = schedule_survey_question
    q.save!
    self.save!
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
