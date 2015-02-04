class AddWelcomeMessageToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :welcome_message, :string, null: false, default: "Welcome to the study! Quit at any time by texting STOP."
  end
end
