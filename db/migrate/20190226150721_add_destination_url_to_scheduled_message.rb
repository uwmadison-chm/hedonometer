class AddDestinationUrlToScheduledMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :scheduled_messages, :destination_url, :text
  end
end
