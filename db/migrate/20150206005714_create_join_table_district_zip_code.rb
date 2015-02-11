class CreateJoinTableDistrictZipCode < ActiveRecord::Migration
  def change
    create_join_table :districts, :zip_codes do |t|
      t.index [:district_id, :zip_code_id]
      t.index [:zip_code_id, :district_id]
    end
  end
end
