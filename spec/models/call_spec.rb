# == Schema Information
#
# Table name: calls
#
#  id         :integer          not null, primary key
#  remote_id  :string
#  person_id  :integer
#  status     :string
#  duration   :integer
#  ended_at   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Call, type: :model do
  describe "#create_connection!" do
    it "creates a connection" do
      call = FactoryGirl.create(:call)
      expect(call.connections).to be_empty

      connection = call.create_connection!
      expect(call.connections.first).to eq(connection)
    end
  end
  describe "#called_legislators" do
    it "returns those legislators who are called" do
      connection = FactoryGirl.create(:connection, :completed)
      call = connection.call

      expect(call.called_legislators).to eq([connection.legislator])
    end
  end
  describe "#random_target" do
    it "returns a legislator" do
      targeted_senator = FactoryGirl.create(:senator, :targeted)
      call = FactoryGirl.build(:call)
      expect(call.random_target).to eq(targeted_senator)
    end
    context "with a called legislator" do
      it "returns only uncalled legislators" do
        legislators = create_list(:representative, 3, :targeted)
        call = FactoryGirl.create(:call)
        call.connections << FactoryGirl.build(:connection, :completed, legislator: legislators[0])
        call.connections << FactoryGirl.build(:connection, :completed, legislator: legislators[1])
        call.save

        expect(call.random_target).to eq(legislators[2])
      end
    end
  end
end
