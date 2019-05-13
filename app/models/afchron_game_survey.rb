
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
    s = participant.state
    if s['game'] == 'gather_data' then
      url_game_survey
    else
      url
    end
  end

  def prepare_game_state participant
    unless participant.state.kind_of? AfchronGameState
      participant.state = AfchronGameState.new
      participant.state.set_defaults!
    end
    # Save back reference so the state knows its own participant, since all 
    # the logic is in the state
    participant.state.participant = participant
    participant.state
  end

  def schedule_participant! participant
    participant.requests_new_schedule = false
    state = prepare_game_state participant
    day = self.advance_to_day_with_time_for_message! participant
    # TODO: Do we care if day is nil?
    state.action_for_day! day
  end


end
