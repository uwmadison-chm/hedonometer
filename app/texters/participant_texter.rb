class ParticipantTexter < ActionTexter::Base
  class << self
    def message_for_participant(participant, message)
      Rails.logger.info("Sending #{message} to #{participant.phone_number}")
      survey = participant.survey
      survey.outgoing_text_messages.build({
              to_number: participant.phone_number.to_e164,
              from_number: survey.phone_number.to_e164,
              message: message
            })
    end

    def build_replacements(participant)
      {
        '{{samples_per_day}}' => participant.survey.samples_per_day,
        '{{login_code}}' => participant.login_code,
        '{{first_date}}' => participant.schedule_days.first.date.to_s(:for_sms),
        '{{last_date}}' => participant.schedule_days.last.date.to_s(:for_sms),
      }
    end

    def message_with_replacements(message, participant)
      message_for_participant(participant,
        do_replacements(message, build_replacements(participant)))
    end

    def welcome_message(participant)
      message_with_replacements(
        participant.survey.welcome_message,
        participant)
    end

    def login_code_message(participant)
      message_with_replacements(
        "Your login code is {{login_code}}. Quit at any time by texting STOP.",
        participant)
    end

    def deliver_scheduled_question!(scheduled_question_id)
      # This one doesn't get replacements; I think that would be a surprise.
      scheduled_question = ScheduledQuestion.find scheduled_question_id
      participant = scheduled_question.schedule_day.participant
      message = message_for_participant(participant, scheduled_question.survey_question.question_text)
      scheduled_question.deliver_and_save_if_possible!(message)
      if scheduled_question.completed?
        new_question = participant.schedule_survey_question_and_save!
        if new_question
          self.delay(run_at: new_question.scheduled_at).deliver_scheduled_question!(new_question.id)
        end
      end
    end
  end
end
