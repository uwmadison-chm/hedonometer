# -*- encoding : utf-8 -*-
require 'time_range'
class ScheduleDay < ActiveRecord::Base
  belongs_to :participant
  validates :participant, presence: true
  validates :date, presence: true, uniqueness: {scope: :participant_id}
  before_validation :adjust_day_length_to_match_survey

  serialize :time_ranges

  has_many :scheduled_questions

  validates :aasm_state, presence: true

  include AASM
  aasm do
    state :waiting, initial: true
    state :running
    state :finished

    event :run do
      transitions from: :waiting, to: :running
    end

    event :finish do
      transitions from: :running, to: :finished
    end

    event :skip do
      transitions from: :waiting, to: :finished
    end
  end

  # TODO: Add validation for time_ranges_string

  def time_ranges_string
    self.time_ranges.map {|tr| tr.to_s}.join(", ")
  end

  def time_ranges_string=(str)
    if str == ""
      self.time_ranges = []
    end
    self.time_ranges = str.split(", ").map {|range_str| TimeRange.from_date_and_string(self.date, range_str)}
  end

  def adjust_day_length_to(length)
    # Either extends the last time_range to make the total day length
    # equal to length, or trims the last time_range. Will drop extra time_ranges
    # entirely, if needed.
    self.time_ranges = time_ranges.take_while {|tr|
      (length > 0).tap do |take|
        if take
          length -= tr.duration
        end
      end
    }
    self.time_ranges.last.end += length
  end

  def starts_at
    time_ranges.first.first
  end

  def survey
    self.participant.survey
  end

  def adjust_day_length_to_match_survey
    adjust_day_length_to(survey.day_length)
  end

  def day_length
    time_ranges.map {|r| r.duration}.reduce(:+)
  end

  def completed_question_count
    scheduled_questions.completed.count
  end

  def current_question
    scheduled_questions.scheduled.first
  end

  def minimum_time_to_question(question_number)
    (((question_number) * survey.mean_minutes_between_samples) - survey.sample_minutes_plusminus).minutes
  end

  def minimum_time_to_next_question
    minimum_time_to_question(completed_question_count + 1)
  end

  def maximum_time_to_question(question_number)
    (((question_number) * survey.mean_minutes_between_samples) + survey.sample_minutes_plusminus).minutes
  end

  def maximum_time_to_next_question
    maximum_time_to_question(completed_question_count + 1)
  end

  def next_question_time_range
    (minimum_time_to_next_question..maximum_time_to_next_question)
  end

  def random_time_for_next_question
    valid_time_after_day_start(rand(next_question_time_range))
  end

  def has_time_for_another_question?
    valid_time_after_day_start(maximum_time_to_next_question)
  end

  def valid_time_after_day_start(future_seconds)
    time_ranges.each do |range|
      if range.duration >= future_seconds
        return range.first + future_seconds
      end
      future_seconds -= range.duration
    end
    nil
  end

  def all_questions_delivered?
    scheduled_questions.delivered.count >= participant.survey.samples_per_day
  end

  def can_deliver_more_questions?
    not all_questions_delivered?
  end
end
