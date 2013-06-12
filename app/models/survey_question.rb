class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey

  validates :question_text, presence: true
end
