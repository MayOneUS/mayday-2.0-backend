class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :remote_id

      t.timestamps null: false
    end
    add_index :events, :remote_id, unique: true
  end
end
