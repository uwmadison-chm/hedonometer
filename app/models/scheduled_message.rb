class ScheduledMessage < ApplicationRecord
  belongs_to :schedule_day
  validates :schedule_day, presence: true

  belongs_to :survey_question, optional: true
  validate :message_or_question

  validates :scheduled_at, presence: true

  scope :completed, -> {
    where(aasm_state: ['delivered', 'aged_out', 'participant_inactive'])}

  scope :pending, -> {
    where(aasm_state: ['scheduled'])}

  include AASM
  aasm do
    state :scheduled, initial: true
    state :delivered, before_enter: :set_delivered_at
    state :aged_out,  before_enter: :log_aging_out
    state :participant_inactive, before_enter: :log_participant_inactive

    event :mark_delivered do
      transitions from: :scheduled, to: :delivered
    end

    event :mark_aged_out do
      transitions from: :scheduled, to: :aged_out
    end

    event :mark_participant_inactive do
      transitions from: :scheduled, to: :participant_inactive
    end
  end

  def message_or_question
    unless message_text.blank? ^ survey_question.blank?
      errors.add(:base, "Need a message or a survey question, not both")
    end
  end

  def message_or_question_text
    message_text || survey_question.question_text
  end

  def participant
    schedule_day.participant
  end

  def survey
    participant.survey
  end

  def set_delivered_at
    self.delivered_at = Time.now
  end

  def completed?
    delivered? or aged_out? or participant_inactive?
  end

  def log_aging_out
    logger.warn "Aging out #{self.to_s}"
  end

  def log_participant_inactive
    logger.warn "Participant inactive for #{self.to_s}"
  end

  def active_participant?
    self.schedule_day.participant.active?
  end

  def deliver_and_save_if_possible!(message)
    return if delivered?
    if can_be_delivered_now?
      message.deliver_and_save!
      self.mark_delivered
    elsif too_old_to_deliver?
      self.mark_aged_out
    elsif not self.schedule_day.participant.active?
      self.mark_participant_inactive
    end
    save!
  end

  def max_age
    schedule_day.participant.survey.mininum_intersample_period
  end

  def too_old_to_deliver?
    younger_than?(max_age)
  end

  def can_be_delivered_now?
    undelivered? and delivery_due? and not too_old_to_deliver? and active_participant?
  end

  def delivered?
    delivered_at
  end

  def undelivered?
    delivered_at.nil?
  end

  def delivery_due?
    scheduled_at and scheduled_at <= Time.now
  end

  def younger_than?(seconds)
    scheduled_at and scheduled_at <= Time.now - seconds
  end
end
