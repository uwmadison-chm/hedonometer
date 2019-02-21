class AddConfigurationToSurvey < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :configuration, :jsonb, default: {}
  end
end
