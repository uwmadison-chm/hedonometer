class AddPhoneNumberToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :phone_number, :string
  end
end
