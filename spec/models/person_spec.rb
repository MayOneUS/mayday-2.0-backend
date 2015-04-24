# == Schema Information
#
# Table name: people
#
#  id           :integer          not null, primary key
#  email        :string
#  phone        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  first_name   :string
#  last_name    :string
#  uuid         :string
#  is_volunteer :boolean
#

require 'rails_helper'

describe Person do

  describe "validations" do
    it "validates with an email and no phone" do
      person = Person.new(email: 'user@example.com')
      expect(person.valid?).to be true
    end
    it "validates with a phone and no email" do
      person = Person.new(phone: '555-555-5555')
      expect(person.valid?).to be true
    end
    it "is invalid with no email or phone" do
      person = Person.new
      expect(person.valid?).to be false
    end
  end

  describe "create" do
    it "generates uuid" do
      person = Person.create(email: 'user@example.com')
      expect(person.uuid).to_not be_nil
      expect(person.uuid.length).to eq 36
    end
  end

  describe "#all_called_legislators" do
    it "returns those legislators who are called" do
      call = FactoryGirl.create(:call)
      connections = create_list(:connection, 2, :completed, call: call)
      connection_three = FactoryGirl.create(:connection, :failed, call: call)
      person = call.person

      expected_ids = person.all_called_legislators.map(&:id)
      expect(expected_ids).to eq(connections.map{|c| c.legislator.id})
      expect(expected_ids).not_to include(connection_three.legislator.id)
    end
  end

  describe ".create_or_update" do
    context "new record" do
      it "creates record with appropriate values" do
        hash = { email:      'user@example.com',
                 phone:      '555-555-1111',
                 first_name: 'Bob',
                 last_name:  'Garfield' }
        person = Person.create_or_update(hash)
        expect(person.slice(*hash.keys).values).to eq hash.values
      end
    end
    context "existing record" do
      it "updates record with appropriate values" do
        person = FactoryGirl.create(:person, email: 'user@example.com')
        hash = { email: 'user@example.com',
                 phone: '555-555-1111' }
        Person.create_or_update(hash)
        expect(person.reload.slice(*hash.keys).values).to eq hash.values
      end
      it "finds user based on uuid, if present" do
        person = FactoryGirl.create(:person, uuid: 'good-uuid', email: 'user@example.com',)
        hash = { email: 'new_email_address@example.com',
                 uuid:  'good-uuid' }
        Person.create_or_update(hash)
        expect(person.reload.slice(*hash.keys).values).to eq hash.values
      end
    end
  end

  describe "#save_location" do

    it "calls update location if zip present" do
      expect_any_instance_of(Location).to receive(:update_location).
        with(address: '2020 Oregon St', zip: '94703') { true }
      Person.create(email: 'user@example.com', address: '2020 Oregon St', zip: '94703')
    end

    it "doesn't update location if zip not present" do
      expect_any_instance_of(Location).not_to receive(:update_location)
      Person.create(email: 'user@example.com', address: '2020 Oregon St')
    end

  end

  describe "#constituent_of?" do
    let(:voter) { FactoryGirl.create(:person, :with_district) }

    it "returns nil if person has no state/district" do
      person = FactoryGirl.create(:person)
      rep = FactoryGirl.create(:representative)
      expect(person.constituent_of? rep).to be_nil
    end

    it "returns true if rep in person's district" do
      rep = FactoryGirl.create(:representative, district: voter.district)
      expect(voter.constituent_of? rep).to be true
    end

    it "returns true if senator in person's state" do
      senator = FactoryGirl.create(:senator, state: voter.state)
      expect(voter.constituent_of? senator).to be true
    end

    it "returns false if rep in other district" do
      rep = FactoryGirl.create(:representative)
      expect(voter.constituent_of? rep).to be false
    end

  end

  describe "targeting" do
    let(:voter)   { FactoryGirl.create(:person, :with_district) }

    describe "#other_targets" do

      it "only returns priority legislators" do
        FactoryGirl.create(:representative, :targeted)
        priority_rep = FactoryGirl.create(:representative, :targeted, priority: 1)

        expect(voter.other_targets(count: 5, excluding: [])).to eq [priority_rep]
      end

      it "excludes legislators" do
        rep1 = FactoryGirl.create(:representative, :targeted, priority: 1)
        rep2 = FactoryGirl.create(:representative, :targeted, priority: 1)

        expect(voter.other_targets(count: 5, excluding: [rep1])).to eq [rep2]
      end

      it "returns correct number of legislators" do
        FactoryGirl.create(:campaign_with_reps, count: 3, priority: 1)
        expect(voter.other_targets(count: 2, excluding: []).count).to eq 2
      end

    end

    describe "#target_legislators" do

      context "normal" do
        subject(:legislators) { voter.target_legislators }

        it "returns default targets for person with no district/state" do
          person = FactoryGirl.create(:person)
          rep = FactoryGirl.create(:representative, :targeted, priority: 1)
          expect(person.target_legislators).to eq [rep]
        end

        it "returns local target followed by other targets" do
          rep = FactoryGirl.create(:representative, :targeted, priority: 1)
          unconvinced_senator = FactoryGirl.create(:senator, state: voter.state)
          expect(legislators).to eq [unconvinced_senator, rep]
        end

        it "doesn't return local targets twice" do
          local_rep = FactoryGirl.create(:representative, :targeted, priority: 1,
                                            district: voter.district)
          other_rep = FactoryGirl.create(:representative, :targeted, priority: 1)
          expect(legislators).to eq [local_rep, other_rep]
        end

        it "doesn't include rep with us" do
          rep_with_us = FactoryGirl.create(:representative, :with_us, district: voter.district)
          expect(legislators).not_to include rep_with_us
        end

        it "doesn't include ineligible senators" do
          senator = FactoryGirl.create(:senator, state: voter.state, term_end: 3.years.from_now)
          expect(legislators).not_to include senator
        end
      end

      context "json" do

        it "works with empty array" do
          person = FactoryGirl.create(:person)
          expect(person.target_legislators(json: true)).to eq []
        end

        it "sets local attribute for all targets" do
          FactoryGirl.create(:senator, state: voter.state)
          FactoryGirl.create(:representative, :targeted, priority: 1)
          locals = voter.target_legislators(json: true).map{|l| l['local']}
          expect(locals).to eq [true, false]
        end

      end

      context "with count arg" do

        it "returns appropriate count" do
          FactoryGirl.create(:campaign_with_reps, count: 3, priority: 1)
          expect(voter.target_legislators(count: 2).count).to eq 2
        end

      end
    end
  end

  describe "#update_nation_builder" do
    context "creating new user" do
      it "sends call to update NationBuilder" do
        expect_any_instance_of(Person).to receive(:update_nation_builder).and_call_original
        expect(NbPersonPushJob).to receive(:perform_later).
          with(email: 'user@example.com', phone: '510-555-1234')
        FactoryGirl.create(:person, email: 'user@example.com', phone:'510-555-1234')
      end
    end
    context "updating existing user" do
      let(:user) { FactoryGirl.create(:person, email: 'user@example.com', phone:'510-555-1234') }
      before { expect(user).to receive(:update_nation_builder).and_call_original }

      it "sends remote_fields to NationBuilder if present" do
        expect(NbPersonPushJob).to receive(:perform_later).
          with(email: 'user@example.com', tags: ['test'], foo: 'bar')
        user.update(remote_fields: { tags: ['test'], foo: 'bar' })
      end

      it "sends call to update NationBuilder if relevant field changed" do
        expect(NbPersonPushJob).to receive(:perform_later).
          with(email: 'user@example.com', first_name: 'Bob')
        user.update(first_name: 'Bob')
      end

      it "doesn't send call to update NationBuilder if no relevant field changed" do
        expect(NbPersonPushJob).not_to receive(:perform_later)
        user.update(phone:'510-555-1234')
      end
    end
  end
end
