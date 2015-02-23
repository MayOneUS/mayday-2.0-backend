class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.string :remote_id
      t.integer :call_id
      t.integer :legislator_id
      t.integer :campaign_id
      t.string :state_from_user
      t.string :state

      t.timestamps null: false
    end
  end
end
