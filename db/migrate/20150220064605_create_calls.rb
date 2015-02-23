class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.string :remote_id
      t.integer :district_id
      t.integer :phone_origin
      t.string :state
      t.datetime :ended_at
      t.string :source

      t.timestamps null: false
    end
  end
end
