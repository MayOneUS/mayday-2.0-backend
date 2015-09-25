class AddIsDefaultToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :is_default, :boolean
  end
end
