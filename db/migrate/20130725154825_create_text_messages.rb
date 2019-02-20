class CreateTextMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :text_messages do |t|
      t.references :survey, null: false
      t.string :type, null: false
      t.index [:survey_id, :type]

      t.string :from, null: false
      t.index [:survey_id, :from]
      t.string :to, null: false
      t.index [:survey_id, :to]

      t.string :message, null: false

      t.text :server_response

      t.datetime :scheduled_at
      t.datetime :delivered_at

      t.timestamps
    end
  end
end
