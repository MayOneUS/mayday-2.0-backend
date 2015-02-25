class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.string :remote_id
      t.integer :district_id
      t.integer :person_id

      t.string :state
      t.datetime :ended_at

      t.timestamps null: false
    end
  end
end
