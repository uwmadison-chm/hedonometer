class AddScheduleToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :schedule, :text
    add_column :participants, :time_zone, :string
  end
end
