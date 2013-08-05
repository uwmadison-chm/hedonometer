class AddSampledDaysToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :sampled_days, :integer, null: false, default: 1
  end
end
