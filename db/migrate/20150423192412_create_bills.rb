class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.string :bill_id
      t.string :chamber
      t.string :short_title
      t.string :summary_short
      t.integer :congressional_session
      t.string :opencongress_url

      t.timestamps null: false
    end
    add_index :bills, :bill_id, unique: true
  end
end
