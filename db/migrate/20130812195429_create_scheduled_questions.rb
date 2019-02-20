class CreateScheduledQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :scheduled_questions do |t|
      t.references :schedule_day, null: false
      t.references :survey_question, null: false
      t.datetime :scheduled_at, null: false
      t.datetime :delivered_at
      t.timestamps
    end
  end
end
