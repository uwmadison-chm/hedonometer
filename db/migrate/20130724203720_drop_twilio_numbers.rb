class DropTwilioNumbers < ActiveRecord::Migration
  def change
    drop_table :twilio_numbers
  end
end
