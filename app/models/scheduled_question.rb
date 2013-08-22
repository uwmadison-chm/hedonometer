class ScheduledQuestion < ActiveRecord::Base
  belongs_to :schedule_day
  validates :schedule_day, presence: true

  belongs_to :survey_question
  validates :survey_question, presence: true

  validates :scheduled_at, presence: true

  scope :completed, -> { where(aasm_state: ['delivered', 'aged_out'])}

  include AASM
  aasm do
    state :scheduled, initial: true
    state :delivered, before_enter: :set_delivered_at
    state :aged_out,  before_enter: :log_aging_out

    event :mark_delivered do
      transitions from: :scheduled, to: :delivered
    end

    event :mark_aged_out do
      transitions from: :scheduled, to: :aged_out
    end
  end

  def set_delivered_at
    self.delivered_at = Time.now
  end

  def log_aging_out
    logger.warn "Aging out #{self.to_s}"
  end

  def deliver_and_save_if_possible!(message)
    if can_be_delivered_now?
      message.deliver_and_save!
      self.mark_delivered
    end
    if too_old_to_deliver?
      self.mark_aged_out
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
    undelivered? and delivery_due? and not too_old_to_deliver?
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
