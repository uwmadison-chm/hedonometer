# -*- encoding : utf-8 -*-
class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.references :survey, null: false
      t.string :phone_number, null: false
      t.boolean :active, null: false, default: true
      t.string :login_code
      t.timestamps
    end
  end
end
