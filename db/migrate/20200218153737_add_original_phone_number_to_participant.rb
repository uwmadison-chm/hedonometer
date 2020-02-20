class AddOriginalPhoneNumberToParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :participants, :original_number, :string, null: true
  end
end
