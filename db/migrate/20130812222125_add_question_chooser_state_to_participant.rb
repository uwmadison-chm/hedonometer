class AddQuestionChooserStateToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :question_chooser_state, :text
  end
end
