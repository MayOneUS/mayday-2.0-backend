class RemoveWithUsFromLegislators < ActiveRecord::Migration
  def change
    remove_column :legislators, :with_us, :string
  end
end
