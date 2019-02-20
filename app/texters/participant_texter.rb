class ParticipantTexter < ActionTexter::Base
  class << self
    def message_for_participant(message, participant)
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
        '{{external_key}}' => participant.external_key,
        '{{samples_per_day}}' => participant.survey.samples_per_day,
        '{{login_code}}' => participant.login_code,
        '{{first_date}}' => participant.schedule_days.first.date.to_s(:for_sms),
        '{{last_date}}' => participant.schedule_days.last.date.to_s(:for_sms),
      }
    end

    def message_with_replacements(message, participant)
      message_for_participant(
        do_replacements(message, build_replacements(participant)),
        participant
      )
    end

    def welcome_message(participant)
      message_with_replacements(
        participant.survey.welcome_message,
        participant)
    end

    def help_message(participant)
      message_with_replacements(
        participant.survey.welcome_message + " ... You can reply STOP to stop all messages or START to start them.",
        participant)
    end

    def start_message(participant)
      message_with_replacements(
        "You have been resubscribed. Reply HELP for help.",
        participant)
    end

    def stop_message(participant)
      message_with_replacements(
        "You have been unsubscribed. No more messages will be sent. Reply HELP for help.",
        participant)
    end

    def login_code_message(participant)
      message_with_replacements(
        "Your login code is {{login_code}}. Quit at any time by texting STOP.",
        participant)
    end

    def deliver_scheduled_question!(scheduled_question_id)
      scheduled_question = ScheduledQuestion.find scheduled_question_id
      participant = scheduled_question.schedule_day.participant
      message = message_with_replacements(
        scheduled_question.survey_question.question_text,
        participant)
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
