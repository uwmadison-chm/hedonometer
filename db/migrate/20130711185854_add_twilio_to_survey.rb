# -*- encoding : utf-8 -*-
class AddTwilioToSurvey < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :twilio_account_sid, :string
    add_column :surveys, :twilio_auth_token, :string
  end
end
