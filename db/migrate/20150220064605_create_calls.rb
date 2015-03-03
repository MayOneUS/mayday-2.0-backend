class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.string :remote_id
      t.belongs_to :person, index: true
      t.string :status
      t.integer :duration
      t.datetime :ended_at

      t.timestamps null: false
    end
  end
end
