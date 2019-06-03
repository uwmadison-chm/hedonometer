class ParticipantTexter < ActionTexter::Base
  class << self
    include ApplicationHelper
    def message_for_participant(message, participant)
      Rails.logger.info("Sending #{message} to #{participant.phone_number}")
      survey = participant.survey
      survey.outgoing_text_messages.build({
              to_number: participant.phone_number.to_e164,
              from_number: survey.phone_number.to_e164,
              message: message
            })
    end

    def build_replacements(participant, scheduled_message)
      {
        '{{external_key}}' => participant.external_key,
        '{{samples_per_day}}' => participant.survey.samples_per_day,
        '{{login_code}}' => participant.login_code,
        '{{first_date}}' => participant.schedule_days.first.participant_local_date.to_s(:for_sms),
        '{{last_date}}' => participant.schedule_days.last.participant_local_date.to_s(:for_sms),
        '{{sent_time}}' => Time.now.strftime("%H:%M"),
        '{{redirect_link}}' => 
          if scheduled_message
            # This is the redirect that goes into text messages to forward people to 
            # say, qualtrics or whatever
            Rails.application.routes.url_for(action: 'show', controller: 'scheduled_messages', id: scheduled_message.id, only_path: false)
          end
      }
    end

    def message_with_replacements(message, participant, scheduled_message=nil)
      message_for_participant(
        do_replacements(message, build_replacements(participant, scheduled_message)),
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

    def deliver_scheduled_message!(scheduled_message_id)
      scheduled_message = ScheduledMessage.find scheduled_message_id
      participant = scheduled_message.schedule_day.participant
      survey = participant.survey
      question = scheduled_message.survey_question
      text =
        if question then
          scheduled_message.survey_question.question_text
        else
          scheduled_message.message_text
        end
      message = message_with_replacements(text, participant, scheduled_message)
      scheduled_message.deliver_and_save_if_possible!(message)
      if scheduled_message.completed?
        new_message = survey.schedule_participant! participant
        unless new_message
          Rails.logger.warn("No subsequent message scheduled after scheduled message #{scheduled_message_id}")
        end
      end
    end
  end
end
