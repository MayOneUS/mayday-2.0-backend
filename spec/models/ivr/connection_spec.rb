# == Schema Information
#
# Table name: connections
#
#  id               :integer          not null, primary key
#  remote_id        :string
#  call_id          :integer
#  legislator_id    :integer
#  status_from_user :string
#  status           :string
#  duration         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

describe Ivr::Connection, type: :model do
  it "validates required associations" do
    connection = Ivr::Connection.new
    connection.valid?

    expect(connection.errors).to have_key(:legislator)
    expect(connection.errors).to have_key(:call)
  end
end
