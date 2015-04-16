class AddUuidAndIsVolunteerToPeople < ActiveRecord::Migration
  def change
    add_column :people, :uuid, :string
    add_column :people, :is_volunteer, :boolean
    add_index :people, :uuid, unique: true

    reversible do |change|
      change.up do
        Person.unscoped.each do |person|
          person.update(uuid: Person.new_uuid)
        end
      end
    end
  end
end
