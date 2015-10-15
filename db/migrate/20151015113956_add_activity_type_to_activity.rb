class AddActivityTypeToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :activity_type, :string
    add_index :activities, :activity_type
  end
end
