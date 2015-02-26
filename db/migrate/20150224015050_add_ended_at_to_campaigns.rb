class AddEndedAtToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :ended_at, :datetime
  end
end
