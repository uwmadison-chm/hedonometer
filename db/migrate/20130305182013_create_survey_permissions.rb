class CreateSurveyPermissions < ActiveRecord::Migration
  def change
    create_table :survey_permissions do |t|
      t.references :admins, null: false
      t.references :surveys, null: false
      t.boolean :can_modify_survey
      t.timestamps
    end
  end
end
