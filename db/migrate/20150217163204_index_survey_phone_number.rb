class IndexSurveyPhoneNumber < ActiveRecord::Migration[4.2]
  def change
    add_index :surveys, [:phone_number, :active]
  end
end
