class TextMessage < ApplicationRecord
  belongs_to :survey
  serialize :server_response, JSON

  serialize :from_number, PhoneNumber
  serialize :to_number, PhoneNumber

  validates :from_number, presence: true
  validates :to_number, presence: true

  validates :survey, presence: true

  def direction
    'Error'
  end

  def participant
    nil
  end

  def participant_external_key
    participant.external_key if participant
  end

  def time_zone
    participant.try(:time_zone) || survey.try(:time_zone) || "UTC"
  end

  def delivered_at_in_zone
    delivered_at.in_time_zone(time_zone)
  end

  class DeliveryError < RuntimeError
  end
end
