class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :location_type
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip_code
      t.integer :person_id
      t.integer :district_id

      t.timestamps null: false
    end
  end
end
