class AddSortOrderToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :sort_order, :integer
  end
end
