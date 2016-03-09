class AddDonorStrikeFieldsToActions < ActiveRecord::Migration
  def change
    add_column :actions, :strike_amount_in_cents, :integer
    add_column :actions, :privacy_status, :integer, default: 0
    add_index :actions, :privacy_status
  end
end
