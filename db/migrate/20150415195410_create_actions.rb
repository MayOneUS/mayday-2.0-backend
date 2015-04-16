class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.belongs_to :person, index: true, null: false
      t.belongs_to :activity, index: true, null: false

      t.timestamps null: false
    end
    add_index :actions, [:person_id, :activity_id]
    add_foreign_key :actions, :people
    add_foreign_key :actions, :activities
  end
end
