class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :location_type
      t.string :address_1
      t.string :address_2
      t.string :city
      t.belongs_to :state, index: true
      t.string :zip_code
      t.belongs_to :person, index: true
      t.belongs_to :district, index: true

      t.timestamps null: false
    end
    add_foreign_key :locations, :states
    add_foreign_key :locations, :people
    add_foreign_key :locations, :districts
  end
end
