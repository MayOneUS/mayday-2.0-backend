class AddCampaignRefToIvrCalls < ActiveRecord::Migration
  def change
    add_column :ivr_calls, :campaign_ref, :string
  end
end
