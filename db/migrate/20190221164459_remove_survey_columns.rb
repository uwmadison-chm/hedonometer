class RemoveSurveyColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :surveys, :samples_per_day
    remove_column :surveys, :mean_minutes_between_samples
    remove_column :surveys, :sample_minutes_plusminus
    remove_column :surveys, :sampled_days
  end
end
