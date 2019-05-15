
class AfchronGameSurvey < Survey
  def self.model_name
    Survey.model_name
  end

  def url
    configuration['url']
  end

  def url= x
    configuration['url'] = x
  end

  def url_game_survey
    configuration['url_game_survey']
  end

  def url_game_survey= x
    configuration['url_game_survey'] = x
  end

  def url_for_participant participant
    # Different survey urls depending on participant state
    s = participant.participant_state
    if s['game'] == 'gather_data' then
      url_game_survey
    else
      url
    end
  end

  def prepare_game_state participant
    unless participant.participant_state.kind_of? AfchronGameState
      participant.participant_state.save
      participant.participant_state.destroy
      state = AfchronGameState.new(:participant => participant)
      participant.participant_state = state
      state.set_defaults!
    end
    participant.participant_state
  end

  def schedule_participant! participant
    participant.requests_new_schedule = false
    state = prepare_game_state participant
    day = self.advance_to_day_with_time_for_message! participant
    unless day
      logger.info("Participant has no more available days")
      return false
    end
    state.action_for_day! day
  end

end
