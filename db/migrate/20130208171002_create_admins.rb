class CreateAdmins < ActiveRecord::Migration
  def change
    create_table :admins do |t|
      t.string :email, null: false, unique: true
      t.string :password_digest, null: false
      t.boolean :can_change_admins, null: false, default: false
      t.boolean :can_create_surveys, null: false, default: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
  end
end
