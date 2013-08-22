class ChangePasswordStuffToBinary < ActiveRecord::Migration
  def change
    change_column :admins, :password_salt, :binary
    change_column :admins, :password_hash, :binary
  end
end
