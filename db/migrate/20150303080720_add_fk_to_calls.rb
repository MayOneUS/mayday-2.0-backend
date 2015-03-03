class AddFkToCalls < ActiveRecord::Migration
  def change
    add_foreign_key :calls, :people
  end
end
