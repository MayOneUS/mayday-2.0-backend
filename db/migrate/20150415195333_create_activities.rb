class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :name
      t.string :template_id

      t.timestamps null: false
    end
    add_index :activities, :template_id, unique: true
  end
end
