class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :name
      t.string :abbrev
      t.boolean :single_district

      t.timestamps null: false
    end
  end
end
