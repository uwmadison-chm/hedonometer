class ParticipantState < ApplicationRecord
  belongs_to :participant
  validates :participant, presence: true

  include AASM
  aasm column: 'aasm_state' do
    state :none, initial: true
  end

  def do_message! message_text, scheduled_at, url=nil, expired_at=nil
    day = self.participant.schedule_days.running_day
    if day
      message = day.scheduled_messages.build(message_text: message_text, scheduled_at: scheduled_at)
      if url
        message.destination_url = url
      elsif participant.survey.url
        message.destination_url = participant.survey.url
      end
      if expired_at
        message.expired_at = expired_at
      end
      message.save!
      Rails.logger.debug("Scheduled #{message.inspect}")
      ParticipantTexter.delay(run_at: message.scheduled_at).deliver_scheduled_message!(message.id)
      return message
    else
      Rails.logger.warn("Could not schedule #{message_text} for #{self.participant.id}, no running_day")
    end
  end
end
