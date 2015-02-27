class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.string :remote_id
      t.integer :call_id
      t.integer :legislator_id
      t.string :status_from_user
      t.string :status
      t.integer :duration

      t.timestamps null: false
    end
  end
end
