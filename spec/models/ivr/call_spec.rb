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

describe Ivr::Call, type: :model do
  describe "#create_connection!" do
    it "creates a connection" do
      FactoryGirl.create(:representative, :targeted, priority: 1)
      call = FactoryGirl.create(:call)
      expect(call.connections).to be_empty

      connection = call.create_connection!
      expect(call.connections.first).to eq(connection)
    end
  end
  describe "#called_legislators" do
    it "returns those legislators who are succesfully called" do
      connection = FactoryGirl.create(:connection, :completed, status_from_user: Ivr::Connection::USER_RESPONSE_CODES['1'])
      call = connection.call

      expect(call.called_legislators).to eq([connection.legislator])
    end
  end
  describe "#attempted_legislators" do
    it "returns those legislators who are called" do
      connection = FactoryGirl.create(:connection)
      call = connection.call

      expect(call.attempted_legislators).to eq([connection.legislator])
    end
  end
  describe "#legislators_targeted" do
    def legislators_targeted_setup(targeted_legislators_count:3)
      @legislators = create_list(:representative, targeted_legislators_count, :targeted, priority: 1)
      @call = FactoryGirl.create(:call)
      @call.connections << FactoryGirl.build(:connection, :completed, legislator: @legislators[0])
      @call.connections << FactoryGirl.build(:connection, :failed, legislator: @legislators[1])
      @call.save
    end
    it "returns a legislator" do
      targeted_senator = FactoryGirl.create(:senator, :targeted, priority: 1)
      call = FactoryGirl.build(:call)
      expect(call.legislators_targeted).to include(targeted_senator)
    end
    context "with current connections" do
      it "doesn't return legislators from recent connections" do
        legislators_targeted_setup
        expect(@call.legislators_targeted).to eq([@legislators.last])
      end
    end
    context "with previously completed calls to legislators" do
      it "returns only uncalled legislators" do
        legislators_targeted_setup

        target_person = @call.person
        second_call = FactoryGirl.create(:call, person: target_person)
        legislators_targeted = second_call.legislators_targeted

        expect(legislators_targeted).to include(@legislators[1])
        expect(legislators_targeted).to include(@legislators[2])
        expect(legislators_targeted).not_to include(@legislators[0])
      end

    end

  end
  describe "#next_target" do
    it "is the next targeted legislator" do
      legislators = create_list(:representative, 4, :targeted, priority: 1)
      call = FactoryGirl.create(:call)
      call.connections << FactoryGirl.build(:connection, :completed, legislator: legislators[0])
      call.connections << FactoryGirl.build(:connection, :failed, legislator: legislators[1])
      call.save
    end
  end
  describe "finished_loop?" do
    def setup_call_with_connections(connections_count=1)
      call = FactoryGirl.build(:call)
      allow(call).to receive(:connections).and_return(Array.new(connections_count,0))
      call
    end
    it "returns false with 3 connections" do
      call = setup_call_with_connections(3)
      expect(call.finished_loop?).to be false
    end
    it "returns true with 5 connections" do
      call = setup_call_with_connections(5)
      expect(call.finished_loop?).to be true
    end
    it "returns false with 7 connections" do
      call = setup_call_with_connections(7)
      expect(call.finished_loop?).to be false
    end
  end
end
