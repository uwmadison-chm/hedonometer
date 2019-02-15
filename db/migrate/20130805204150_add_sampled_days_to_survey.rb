class AddSampledDaysToSurvey < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :sampled_days, :integer, null: false, default: 1
  end
end
