class AddQuestionChooserStateToParticipant < ActiveRecord::Migration[4.2]
  def change
    add_column :participants, :question_chooser_state, :text
  end
end
