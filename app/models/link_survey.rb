class LinkSurvey < Survey
  def self.model_name
    Survey.model_name
  end

  def url
    self.configuration['url']
  end

  def url= x
    self.configuration['url'] = x
  end

  def schedule_participant! participant
    participant.participant_state ||= SimpleParticipantState.new(:participant => participant)
    participant.requests_new_schedule = false
    day = self.advance_to_day_with_time_for_message! participant
    return nil unless day
    message_text = "Please take this survey now (sent at {{sent_time}}): {{redirect_link}}"
    message = day.scheduled_messages.build(message_text: message_text)
    message.scheduled_at = day.random_time_for_next_question
    message.destination_url = self.url
    message.save!
    logger.debug("Scheduled #{message.inspect}")
    ParticipantTexter.delay(run_at: message.scheduled_at).deliver_scheduled_message!(message.id)
    return message
  end
end

