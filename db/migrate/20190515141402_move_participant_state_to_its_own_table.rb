class MoveParticipantStateToItsOwnTable < ActiveRecord::Migration[5.2]
  def change
    create_table :participant_states do |t|
      t.string :type, null: false
      t.references :participant, null: false
      t.string :aasm_state
      t.json :state, null: false, default: {}
      t.timestamps
    end
    remove_column :participants, :state
  end
end
