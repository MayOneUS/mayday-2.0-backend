class AddWithUsToLegislators < ActiveRecord::Migration
  def change
    add_column :legislators, :with_us, :boolean, default: false
  end
end
