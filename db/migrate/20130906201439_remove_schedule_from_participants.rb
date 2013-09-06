class RemoveScheduleFromParticipants < ActiveRecord::Migration
  def change
    remove_column :participants, :schedule
  end
end
