class AllowNullQuestionOnScheduledMessage < ActiveRecord::Migration[5.2]
  def change
    change_column_null :scheduled_messages, :survey_question_id, true
  end
end
