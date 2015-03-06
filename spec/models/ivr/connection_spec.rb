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

  def connecting_message_for(senator: false,constituent_of: false)
    legislator = double('legislator')
    allow(legislator).to receive(:senator?).and_return(senator)
    person = double('person')
    allow(person).to receive(:constituent_of?).and_return(constituent_of)
    connection = Ivr::Connection.new
    allow(connection).to receive(:person).and_return(person)
    allow(connection).to receive(:legislator).and_return(legislator)
    connection.connecting_message_key
  end

  describe "#connecting_message_key" do
    it "return senator message for a senator" do
      returned_key = connecting_message_for(senator: true)
      expect(returned_key).to eq('connecting_to_senator')
    end
    it "returns a rep message for a rep" do
      returned_key = connecting_message_for
      expect(returned_key).to eq('connecting_to_rep')
    end
    it "returns a local rep for a person's local rep" do
      returned_key = connecting_message_for(constituent_of: true)
      expect(returned_key).to eq('connecting_to_rep_local')
    end
  end
end
