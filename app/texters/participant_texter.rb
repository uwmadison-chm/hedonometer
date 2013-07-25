class ParticipantTexter < ActionTexter::Base
  class << self
    def login_code_message(participant)
      message_for_participant(participant, "Your login code is #{participant.login_code}")
    end
  end
end
