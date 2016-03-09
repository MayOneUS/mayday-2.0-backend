class CreateDonationPages < ActiveRecord::Migration
  def change
    enable_extension 'citext'
    enable_extension 'uuid-ossp'
    create_table :donation_pages do |t|
      t.belongs_to :person, index: true, null: false
      t.string :title, null: false
      t.citext :slug, null: false
      t.string :visible_user_name
      t.string :photo_url
      t.text :intro_text
      t.integer :goal_in_cents
      t.uuid :uuid, default: 'uuid_generate_v4()'

      t.timestamps null: false
    end
    add_index :donation_pages, :uuid, unique: true
    add_index :donation_pages, :slug, unique: true
    add_foreign_key :donation_pages, :people
  end
end
