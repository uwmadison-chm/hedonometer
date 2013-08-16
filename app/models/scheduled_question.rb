class ScheduledQuestion < ActiveRecord::Base
  belongs_to :schedule_day
  validates :schedule_day, presence: true

  belongs_to :survey_question
  validates :survey_question, presence: true

  validates :scheduled_at, presence: true

  scope :delivered, -> { where.not(delivered_at: nil).order('scheduled_at desc') }
  scope :undelivered, -> { where(delivered_at: nil).order('scheduled_at desc') }

  def deliver_and_save_if_possible!(message)
    if can_be_delivered_now?
      message.deliver_and_save!
      self.delivered_at = Time.now
    end
    if aged_out?
      logger.warn("oh man scheduled_question #{id} aged out")
      self.delivered_at = Time.now
    end
    save!
  end

  def max_age
    schedule_day.participant.survey.mininum_intersample_period
  end

  def aged_out?
    younger_than?(max_age)
  end

  def can_be_delivered_now?
    undelivered? and delivery_due? and not aged_out?
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
