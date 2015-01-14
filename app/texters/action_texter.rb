module ActionTexter
  class Base < AbstractController::Base
    class << self
      def message_for_participant(participant, message)
        Rails.logger.info("Sending #{message} to #{participant}")
        survey = participant.survey
        survey.outgoing_text_messages.build({
                to_number: participant.phone_number.to_e164,
                from_number: survey.phone_number.to_e164,
                message: message
              })
      end
    end
  end
end