class GameSurvey < Survey
  def self.model_name
    Survey.model_name
  end

  def schedule_participant! participant
    return false
  end
end
