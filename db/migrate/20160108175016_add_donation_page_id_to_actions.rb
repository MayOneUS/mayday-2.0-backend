class AddDonationPageIdToActions < ActiveRecord::Migration
  def change
    add_reference :actions, :donation_page, index: true
    add_foreign_key :actions, :donation_pages
  end
end
