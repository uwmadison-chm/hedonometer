class AddMessageTextToScheduledMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :scheduled_messages, :message_text, :text
  end
end
