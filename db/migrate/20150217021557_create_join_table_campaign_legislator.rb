class CreateJoinTableCampaignLegislator < ActiveRecord::Migration
  def change
    create_join_table :campaigns, :legislators do |t|
      t.index [:campaign_id, :legislator_id], unique: true
      t.index [:legislator_id, :campaign_id]
    end
  end
end
