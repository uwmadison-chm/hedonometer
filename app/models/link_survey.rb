class LinkSurvey < Survey
  def self.model_name
    Survey.model_name
  end

  def schedule_survey_question_on_participant! participant
    return false
  end
end

