class AddExternalKeyToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :external_key, :string
  end
end
