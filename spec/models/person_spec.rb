# == Schema Information
#
# Table name: people
#
#  id         :integer          not null, primary key
#  email      :string
#  phone      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe Person do

  describe "validations" do
    it "validates with an email and no phone" do
      person = Person.new(email: 'user@example.com')
      person.valid?
      expect(person.valid?).to be true
    end
    it "validates with a phone and no email" do
      person = Person.new(phone: '555-555-5555')
      person.save!
      expect(person.valid?).to be true
    end
    it "is invalid with no email or phone" do
      person = Person.new
      expect(person.valid?).to be false
    end
  end
  describe "#called_legislators" do
    it "returns those legislators who are called" do
      connection = FactoryGirl.create(:connection, :completed)
      person = connection.call.person

      expect(person.called_legislators).to eq([connection.legislator])
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
        expect(Integration::NationBuilder).to receive(:create_or_update_person)
          .with({ attributes: { email: 'user@example.com', phone: '510-555-1234' } })
        FactoryGirl.create(:person, email: 'user@example.com', phone:'510-555-1234')
      end
    end
    context "updating existing user" do
      let(:user) { FactoryGirl.create(:person, email: 'user@example.com', phone:'510-555-1234') }
      before { expect(user).to receive(:update_nation_builder).and_call_original }

      it "sends call to update Nation if relevant field changed" do
        expect(Integration::NationBuilder).to receive(:create_or_update_person)
          .with({ attributes: { email: 'user@example.com', phone: '510-555-9999' } })
        user.update(phone:'510-555-9999')
      end

      it "doesn't send call to update NationBuilder if no relevant field changed" do
        expect(Integration::NationBuilder).not_to receive(:create_or_update_person)
        user.update(phone:'510-555-1234')
      end
    end
  end
end
