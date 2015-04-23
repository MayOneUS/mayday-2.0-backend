class CreateSponsorships < ActiveRecord::Migration
  def change
    create_table :sponsorships do |t|
      t.belongs_to :bill, index: true, null: false
      t.belongs_to :legislator, index: true, null: false
      t.datetime :pledged_support_at
      t.datetime :cosponsored_at
      t.datetime :introduced_at

      t.timestamps null: false
    end
    add_foreign_key :sponsorships, :bills
    add_foreign_key :sponsorships, :legislators
  end
end
