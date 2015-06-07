class CreateIvrRecordings < ActiveRecord::Migration
  def change
    create_table :ivr_recordings do |t|
      t.integer :duration
      t.string :recording_url, :state
      t.belongs_to :call, index: true

      t.timestamps null: false
    end

    rename_table :calls, :ivr_calls
    rename_table :connections, :ivr_connections
  end
end
