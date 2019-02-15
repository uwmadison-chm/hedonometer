class RenameFromAndToColumns < ActiveRecord::Migration[4.2]
  def change
    rename_column :text_messages, :from, :from_number
    rename_column :text_messages, :to, :to_number
  end
end
