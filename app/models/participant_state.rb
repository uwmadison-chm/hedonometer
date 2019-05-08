require "ostruct"

class ParticipantState < OpenStruct
  include AASM
  # TODO: How to serialize and deserialize state?

  def set_defaults
    self.information = {:hooray => "yes"}
  end
  
  aasm do
    state :none, initial: true
  end

end

