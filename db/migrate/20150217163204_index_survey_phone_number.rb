class IndexSurveyPhoneNumber < ActiveRecord::Migration
  def change
    add_index :surveys, [:phone_number, :active]
  end
end
