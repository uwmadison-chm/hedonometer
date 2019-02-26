class AddTypeToSurvey < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :type, :string
  end
end
