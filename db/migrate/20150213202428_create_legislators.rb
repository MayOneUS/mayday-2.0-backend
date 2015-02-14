class CreateLegislators < ActiveRecord::Migration
  def change
    create_table :legislators do |t|
      t.string :bioguide_id, null: false
      t.date :birthday
      t.string :chamber
      # t.string :contact_form
      # t.string :crp_id
      t.belongs_to :district, index: true
      t.string :facebook_id
      # t.string :fax
      t.string :first_name
      t.string :gender
      # t.string :govtrack_id
      # t.string :icpsr_id
      t.boolean :in_office
      t.string :last_name
      # t.string :lis_id
      t.string :middle_name
      t.string :name_suffix
      t.string :nickname
      # t.string :oc_email
      # t.string :ocd_id
      t.string :office
      t.string :party
      t.string :phone
      t.integer :senate_class
      t.belongs_to :state, index: true
      t.string :state_rank
      t.date :term_end
      t.date :term_start
      # t.string :thomas_id
      t.string :title
      # t.string :twitter_id
      # t.string :votesmart_id
      # t.string :website
      # t.string :youtube_id

      t.timestamps null: false
    end
    add_foreign_key :legislators, :districts
    add_foreign_key :legislators, :states
    add_index :legislators, :bioguide_id, unique: true
  end
end
