class TextMessage < ActiveRecord::Base
  belongs_to :survey

  class DeliveryError < RuntimeError
  end
end