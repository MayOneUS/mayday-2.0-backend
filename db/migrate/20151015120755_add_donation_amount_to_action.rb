class AddDonationAmountToAction < ActiveRecord::Migration
  def change
    add_column :actions, :donation_amount, :float
    add_index :actions, :donation_amount
  end
end
