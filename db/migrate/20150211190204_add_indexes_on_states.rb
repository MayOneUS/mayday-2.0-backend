class AddIndexesOnStates < ActiveRecord::Migration
  def change
    add_index :states, :name, unique: true
    add_index :states, :abbrev, unique: true
  end
end
