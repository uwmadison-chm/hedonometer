class RemoveCanCreateSurveys < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        remove_column :admins, :can_create_surveys
      end

      dir.down do
        add_column :admins, :can_create_surveys, :boolean, null: false, default: true
      end
    end
  end
end
