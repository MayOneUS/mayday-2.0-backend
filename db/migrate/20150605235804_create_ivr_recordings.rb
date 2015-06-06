class CreateIvrRecordings < ActiveRecord::Migration
  def change
    create_table :ivr_recordings do |t|
      t.integer :duration
      t.string :remote_url, :state
      t.belongs_to :call, index: true

      t.timestamps null: false
    end
  end
end
