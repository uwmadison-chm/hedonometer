class AddDeletedAtToAdmins < ActiveRecord::Migration
  def change
    remove_column :admins, :active
    add_column :admins, :deleted_at, :datetime
  end
end