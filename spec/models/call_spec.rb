# == Schema Information
#
# Table name: calls
#
#  id          :integer          not null, primary key
#  remote_id   :string
#  district_id :integer
#  person_id   :integer
#  state       :string
#  ended_at    :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Call, type: :model do
  describe "#create_connection!" do
    it "should create a connection" do
      FactoryGirl.create(:representative)
      call = FactoryGirl.create(:call)
      expect(call.connections).to be_empty
      connection = call.create_connection!
      expect(call.connections.first).to eq(connection)
    end
  end
  describe "#targeted_legislators" do
    pending
  end
  describe "#called_legislators" do
    pending
  end
  describe "#random_target" do
    pending
  end
end
