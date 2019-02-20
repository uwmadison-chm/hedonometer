# -*- encoding : utf-8 -*-
class AddDeletedAtToAdmins < ActiveRecord::Migration[4.2]
  def change
    remove_column :admins, :active
    add_column :admins, :deleted_at, :datetime
  end
end
