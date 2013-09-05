class TextMessage < ActiveRecord::Base
  belongs_to :survey
  serialize :server_response, JSON

  serialize :from, PhoneNumber
  serialize :to, PhoneNumber

  validates :from, presence: true
  validates :to, presence: true

  validates :survey, presence: true

  def direction
    'Error'
  end

  class DeliveryError < RuntimeError
  end
end