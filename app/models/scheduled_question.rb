class ScheduledQuestion < ActiveRecord::Base
  belongs_to :schedule_day
  validates :schedule_day, presence: true

  belongs_to :survey_question
  validates :survey_question, presence: true

  validates :scheduled_at, presence: true

  scope :delivered, -> { where.not(delivered_at: nil).order('scheduled_at desc') }
  scope :undelivered, -> { where(delivered_at: nil).order('scheduled_at desc') }

  def can_be_delivered_now?(max_age)
    undelivered? and delivery_due? and younger_than?(max_age)
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
