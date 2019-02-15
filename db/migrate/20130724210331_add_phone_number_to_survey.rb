class AddPhoneNumberToSurvey < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :phone_number, :string
  end
end
