class AddStuffToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :time_zone, :string
    add_column :surveys, :help_message, :text
  end
end
