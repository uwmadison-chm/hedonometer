class AddScheduleToParticipants < ActiveRecord::Migration[4.2]
  def change
    add_column :participants, :schedule, :text
    add_column :participants, :time_zone, :string
  end
end
