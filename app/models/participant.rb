class Participant < ActiveRecord::Base
  validates :phone_number, presence: true, uniqueness: {scope: :survey_id}
  validates :survey, presence: true
  belongs_to :survey
end
