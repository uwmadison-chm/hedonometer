# -*- encoding : utf-8 -*-
class CreateSurveyPermissions < ActiveRecord::Migration[4.2]
  def change
    create_table :survey_permissions do |t|
      t.references :admin, null: false
      t.references :survey, null: false
      t.boolean :can_modify_survey
      t.timestamps
    end
  end
end
