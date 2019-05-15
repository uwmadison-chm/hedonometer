class ParticipantState < ApplicationRecord
  belongs_to :participant
  validates :participant, presence: true
  before_save :set_id

  include AASM
  aasm column: 'aasm_state' do
    state :none, initial: true
  end

  def set_id
    self.participant_id = participant.id
  end

  def [] x
    state[x]
  end

  def []= x, value
    state[x] = value
  end
end
