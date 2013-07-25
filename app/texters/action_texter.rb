module ActionTexter
  class Base < AbstractController::Base
    class << self
      def message_for_participant(participant, message)
        survey = participant.survey
        survey.outgoing_text_messages.build({
                to: participant.phone_number.to_e164,
                from: survey.phone_number.to_e164,
                message: message
              })
      end
    end
  end
end