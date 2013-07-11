class CreateTwilioNumbers < ActiveRecord::Migration
  def change
    create_table :twilio_numbers do |t|
      t.references :survey, null: false
      t.string :phone_number, null: false
      t.string :phone_number_sid, null: false
      t.index :phone_number, :unique => true
      t.timestamps
    end
  end
end
