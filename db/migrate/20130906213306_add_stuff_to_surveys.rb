class AddStuffToSurveys < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :time_zone, :string
    add_column :surveys, :help_message, :text
  end
end
