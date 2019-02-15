# -*- encoding : utf-8 -*-
class AddUniqueIndexToAdminEmail < ActiveRecord::Migration[4.2]
  def change
    add_index :admins, :email, :unique => true
  end
end
