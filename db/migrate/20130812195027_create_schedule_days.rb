class CreateScheduleDays < ActiveRecord::Migration[4.2]
  def change
    create_table :schedule_days do |t|
      t.references :participant, null: false
      t.date :date, null: false
      t.text :time_ranges
      t.boolean :skip, null: false, default: false
      t.timestamps
    end
  end
end
