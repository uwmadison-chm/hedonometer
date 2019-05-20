class ParticipantState < ApplicationRecord
  belongs_to :participant
  validates :participant, presence: true

  include AASM
  aasm column: 'aasm_state' do
    state :none, initial: true
  end

  def do_message! message_text, scheduled_at
    day = self.participant.schedule_days.running_day
    message = day.scheduled_messages.build(message_text: message_text, scheduled_at: scheduled_at)
    message.save!
    Rails.logger.debug("Scheduled #{message.inspect}")
    ParticipantTexter.delay(run_at: message.scheduled_at).deliver_scheduled_message!(message.id)
    return message
  end
end
