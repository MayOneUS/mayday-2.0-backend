class AddCampaignIdToIvrCalls < ActiveRecord::Migration
  def change
    add_column :ivr_calls, :campaign_id, :integer
  end
end
