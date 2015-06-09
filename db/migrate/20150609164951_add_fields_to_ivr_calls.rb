class AddFieldsToIvrCalls < ActiveRecord::Migration
  def change
    add_column :ivr_calls, :call_type, :string
    add_column :ivr_calls, :remote_origin_phone, :string
  end
end
