class CreateZipCodes < ActiveRecord::Migration
  def change
    create_table :zip_codes do |t|
      t.string :zip_code
      t.string :city
      t.belongs_to :state, index: true
      t.integer :district_count
      t.boolean :on_house_gov
      t.datetime :last_checked

      t.timestamps null: false
    end
    add_foreign_key :zip_codes, :states
    add_index :zip_codes, :zip_code, unique: true
  end
end
