class AddSimulatedFlagToTextMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :text_messages, :simulated, :boolean, null: false, default: false
  end
end
