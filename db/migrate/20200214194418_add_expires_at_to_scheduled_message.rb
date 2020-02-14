class AddExpiresAtToScheduledMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :scheduled_messages, :expires_at, :datetime, null: true
  end
end
