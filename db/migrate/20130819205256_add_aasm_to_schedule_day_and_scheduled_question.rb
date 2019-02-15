class AddAasmToScheduleDayAndScheduledQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :schedule_days, :aasm_state, :string
    add_column :scheduled_questions, :aasm_state, :string
    add_index :schedule_days, :aasm_state
    add_index :scheduled_questions, :aasm_state
  end
end
