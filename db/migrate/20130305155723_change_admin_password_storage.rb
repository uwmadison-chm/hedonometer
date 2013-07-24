# -*- encoding : utf-8 -*-
class ChangeAdminPasswordStorage < ActiveRecord::Migration
  def change
    remove_column :admins, :password_digest
    add_column :admins, :password_salt, :string
    add_column :admins, :password_hash, :string
  end
end
