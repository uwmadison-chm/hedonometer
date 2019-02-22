class SimpleSurvey < Survey
  def self.model_name
    Survey.model_name
  end

  has_many :survey_questions, foreign_key: 'survey_id'
  accepts_nested_attributes_for :survey_questions,
    allow_destroy: true,
    reject_if: ->(attributes) { attributes[:question_text].blank? }

end

