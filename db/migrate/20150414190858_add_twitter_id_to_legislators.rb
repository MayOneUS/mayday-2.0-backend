class AddTwitterIdToLegislators < ActiveRecord::Migration
  def change
    add_column :legislators, :twitter_id, :string
  end
end
