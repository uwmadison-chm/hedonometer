# -*- encoding : utf-8 -*-
class AddUniqueIndexToAdminEmail < ActiveRecord::Migration
  def change
    add_index :admins, :email, :unique => true
  end
end
