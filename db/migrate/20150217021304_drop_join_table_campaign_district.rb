class DropJoinTableCampaignDistrict < ActiveRecord::Migration
  def change
    drop_join_table :campaigns, :districts do |t|
      t.index [:campaign_id, :district_id]
      t.index [:district_id, :campaign_id]
    end
  end
end
