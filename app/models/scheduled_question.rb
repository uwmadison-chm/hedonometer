class ScheduledQuestion < ActiveRecord::Base
  belongs_to :schedule_day
  belongs_to :survey_question

  scope :delivered, -> { where.not(delivered_at: nil).order('scheduled_at desc') }
  scope :undelivered, -> { where(delivered_at: nil).order('scheduled_at desc') }
end
