class AddOfficialTitleToBills < ActiveRecord::Migration
  def change
    add_column :bills, :official_title, :string
  end
end
