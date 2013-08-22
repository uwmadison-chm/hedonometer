class ParticipantTexter < ActionTexter::Base
  class << self
    def login_code_message(participant)
      message_for_participant(participant, "Your login code is #{participant.login_code}")
    end

    def deliver_scheduled_question!(scheduled_question_id)
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
