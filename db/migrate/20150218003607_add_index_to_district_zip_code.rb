class AddIndexToDistrictZipCode < ActiveRecord::Migration
  def up
    remove_index :districts_zip_codes, [:zip_code_id, :district_id]
    add_index :districts_zip_codes, [:zip_code_id, :district_id], unique: true
  end
  def down
    remove_index :districts_zip_codes, [:zip_code_id, :district_id]
    add_index :districts_zip_codes, [:zip_code_id, :district_id]
  end
end
