class CreateTargets < ActiveRecord::Migration
  def change
    create_table :targets do |t|
      t.belongs_to :campaign, index: true
      t.belongs_to :legislator, index: true
      t.integer :priority

      t.timestamps null: false
    end
    add_foreign_key :targets, :campaigns
    add_foreign_key :targets, :legislators
    add_index :targets, [:legislator_id, :campaign_id], unique: true
  end
end
