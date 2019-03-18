class RenameScheduledQuestionToScheduledMessage < ActiveRecord::Migration[5.2]
  def change
    rename_index :scheduled_questions, 'index_scheduled_questions_on_aasm_state', 'index_scheduled_messages_on_aasm_state'
    rename_table :scheduled_questions, :scheduled_messages
  end
end
