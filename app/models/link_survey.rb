class LinkSurvey < Survey
  def self.model_name
    Survey.model_name
  end

  def url
    configuration['url']
  end

  def url= x
    configuration['url'] = x
  end

  def schedule_participant! participant
    participant.requests_new_schedule = false
    day = participant.schedule_days.advance_to_day_with_time_for_message!
    message_text = "Please take this survey now (sent at {{sent_time}}): {{redirect_link}}"
    message = day.scheduled_messages.build(message_text: message_text)
    message.scheduled_at = day.random_time_for_next_question
    message.save!
    message
  end
end

