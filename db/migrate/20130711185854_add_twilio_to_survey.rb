class AddTwilioToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :twilio_account_sid, :string
    add_column :surveys, :twilio_auth_token, :string
  end
end
