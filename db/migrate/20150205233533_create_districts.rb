class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.string :district
      t.belongs_to :state, index: true

      t.timestamps null: false
    end
    add_foreign_key :districts, :states
  end
end
