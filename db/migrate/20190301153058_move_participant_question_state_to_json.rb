class MoveParticipantQuestionStateToJson < ActiveRecord::Migration[5.2]
  def change
    add_column :participants, :state, :jsonb, default: {}
    remove_column :participants, :question_chooser_state
  end
end
