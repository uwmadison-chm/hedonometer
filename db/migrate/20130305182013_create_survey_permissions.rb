class CreateSurveyPermissions < ActiveRecord::Migration
  def change
    create_table :survey_permissions do |t|
      t.references :admin, null: false
      t.references :survey, null: false
      t.boolean :can_modify_survey
      t.timestamps
    end
  end
end
