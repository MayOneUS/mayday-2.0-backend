class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.string :remote_id
      t.belongs_to :call, index: true
      t.belongs_to :legislator, index: true
      t.string :status_from_user
      t.string :status
      t.integer :duration

      t.timestamps null: false
    end
    add_foreign_key :connections, :calls
    add_foreign_key :connections, :legislators
  end
end
