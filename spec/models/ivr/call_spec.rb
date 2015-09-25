# == Schema Information
#
# Table name: ivr_calls
#
#  id                  :integer          not null, primary key
#  remote_id           :string
#  person_id           :integer
#  status              :string
#  duration            :integer
#  ended_at            :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  call_type           :string
#  remote_origin_phone :string
#  campaign_ref        :string
#  campaign_id         :integer
#

require 'rails_helper'

describe Ivr::Call, type: :model do
  describe "#create" do
    context "with an active default campaign" do
      it "stores the default as the parent campaign" do
        default_campaign = FactoryGirl.create(:campaign, is_default: true)
        call = FactoryGirl.create(:call)
        expect(call.campaign).to eq(default_campaign)
      end
      it "won't reset a call's existing campaign" do
        default_campaign = FactoryGirl.create(:campaign, is_default: true)
        other_campaign = FactoryGirl.create(:campaign)
        call = FactoryGirl.create(:call, campaign: other_campaign)
        expect(call.campaign).to eq(other_campaign)
      end
    end
  end
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

      it "returns legislators that haven been called in other campaigns" do
        legislators_targeted_setup
        alternative_campaign = FactoryGirl.create(:campaign_with_reps, count: 3)
        target_in_two_campaigns = FactoryGirl.create(:rep_target, legislator: @legislators[0])

        target_person = @call.person
        second_call = FactoryGirl.create(:call, person: target_person, campaign_id: target_in_two_campaigns.campaign_id)
        legislators_targeted = second_call.legislators_targeted

        expect(legislators_targeted).to include(target_in_two_campaigns.legislator)
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
    it "returns false with loop_max_size-2 connections" do
      call = setup_call_with_connections(Ivr::Call::CONNECTION_LOOP_MAX - 2)
      expect(call.finished_loop?).to be false
    end
    it "returns true with loop_max_size connections" do
      call = setup_call_with_connections(Ivr::Call::CONNECTION_LOOP_MAX)
      expect(call.finished_loop?).to be true
    end
    it "returns false with loop_max_size+2 connections" do
      call = setup_call_with_connections(Ivr::Call::CONNECTION_LOOP_MAX + 2)
      expect(call.finished_loop?).to be false
    end
  end
end
