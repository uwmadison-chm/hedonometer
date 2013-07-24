# -*- encoding : utf-8 -*-
class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string :name, null: false
      t.integer :samples_per_day, null: false, default: 4
      t.integer :mean_minutes_between_samples, null: false, default: 60
      t.integer :sample_minutes_plusminus, null: false, default: 15
      t.boolean :active
      t.timestamps
    end
  end
end
