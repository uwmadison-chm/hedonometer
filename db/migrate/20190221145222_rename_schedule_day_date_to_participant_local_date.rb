class RenameScheduleDayDateToParticipantLocalDate < ActiveRecord::Migration[5.2]
  def change
    rename_column :schedule_days, :date, :participant_local_date
  end
end
