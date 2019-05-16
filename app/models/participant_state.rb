class ParticipantState < ApplicationRecord
  belongs_to :participant
  validates :participant, presence: true

  include AASM
  aasm column: 'aasm_state' do
    state :none, initial: true
  end

end
