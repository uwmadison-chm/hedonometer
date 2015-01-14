# -*- encoding : utf-8 -*-
class ChangeAdminPasswordStorage < ActiveRecord::Migration
  def change
    remove_column :admins, :password_digest
    add_column :admins, :password_salt, :binary, :limit => 1.kilobyte
    add_column :admins, :password_hash, :binary, :limit => 1.kilobyte
  end
end
