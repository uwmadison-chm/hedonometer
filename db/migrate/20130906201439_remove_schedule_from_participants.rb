class RemoveScheduleFromParticipants < ActiveRecord::Migration[4.2]
  def change
    remove_column :participants, :schedule
  end
end
