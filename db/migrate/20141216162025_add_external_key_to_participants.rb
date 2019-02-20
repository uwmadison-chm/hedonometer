class AddExternalKeyToParticipants < ActiveRecord::Migration[4.2]
  def change
    add_column :participants, :external_key, :string
  end
end
