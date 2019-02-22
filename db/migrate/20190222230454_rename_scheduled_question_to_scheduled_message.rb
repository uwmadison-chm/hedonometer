class RenameScheduledQuestionToScheduledMessage < ActiveRecord::Migration[5.2]
  def change
    rename_table :scheduled_questions, :scheduled_messages
    rename_index :scheduled_messages, 'index_scheduled_questions_on_aasm_state', 'index_scheduled_messages_on_aasm_state'
  end
end
