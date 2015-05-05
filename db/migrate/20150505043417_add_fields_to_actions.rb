class AddFieldsToActions < ActiveRecord::Migration
  def change
    add_column :actions, :utm_source, :string
    add_column :actions, :utm_medium, :string
    add_column :actions, :utm_campaign, :string
    add_column :actions, :source_url, :string
  end
end
