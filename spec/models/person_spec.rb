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
  describe "#called_legislators" do
    it "returns those legislators who are called" do
      connection = FactoryGirl.create(:connection, :completed)
      person = connection.call.person

      expect(person.called_legislators).to eq([connection.legislator])
    end
  end

  describe "#constituent_of?" do
    let(:senator) { FactoryGirl.create(:senator) }
    let(:rep) { FactoryGirl.create(:representative) }

    it "returns nil if person has no state/district" do
      person = FactoryGirl.build(:person)
      expect(person.constituent_of? rep).to be_nil
    end

    it "returns true if rep in person's district" do
      person = FactoryGirl.create(:person, district: rep.district)
      expect(person.constituent_of? rep).to be true
    end

    it "returns true if senator in person's state" do
      person = FactoryGirl.create(:person, state: senator.state)
      expect(person.constituent_of? senator).to be true
    end

    it "returns false if senator in other state" do
      person = FactoryGirl.create(:person, state: FactoryGirl.create(:state))
      expect(person.constituent_of? senator).to be false
    end

  end

  describe "#target_legislators" do
    let(:district) { FactoryGirl.create(:district) }
    let(:person)   { FactoryGirl.create(:person, district: district,
                                                 state:    district.state) }
    let!(:campaign) { FactoryGirl.create(:campaign_with_reps, count: 5, priority: 1) }
    let!(:rep_with_us) { FactoryGirl.create(:representative, with_us: true, district: district) }
    let!(:unconvinced_senator) {FactoryGirl.create(:senator, with_us: false, state: district.state) }

    context "normal" do
      subject(:legislators) { person.target_legislators }

      it "returns local senator first" do
        expect(legislators.first).to eq unconvinced_senator
      end

      it "doesn't include rep with us" do
        expect(legislators).not_to include rep_with_us
      end

      it "returns 5 legislators" do
        expect(legislators.count).to eq 5
      end
    end

    context "json" do
      subject(:legislators) { person.target_legislators(json: true) }

      it "sets local attribute for all targets" do
        locals = legislators.map{|l| l['local']}
        expect(locals).to eq [true, false, false, false, false]
      end

    end

    context "with count arg" do
      subject(:legislators) { person.target_legislators(count: 3) }

      it "returns appropriate count" do
        expect(legislators.count).to eq 3
      end

    end
  end

  describe "#update_nation_builder" do
    context "creating new user" do
      it "sends call to update NationBuilder" do
        expect_any_instance_of(Person).to receive(:update_nation_builder).and_call_original
        expect(NbPersonPushJob).to receive(:perform_later)
          .with("email"=>"user@example.com", "phone"=>"510-555-1234")
        FactoryGirl.create(:person, email: 'user@example.com', phone:'510-555-1234')
      end
    end
    context "updating existing user" do
      let(:user) { FactoryGirl.create(:person, email: 'user@example.com', phone:'510-555-1234') }
      before { expect(user).to receive(:update_nation_builder).and_call_original }

      it "sends call to update NationBuilder if relevant field changed" do
        expect(NbPersonPushJob).to receive(:perform_later)
          .with("email"=>"user@example.com", "phone"=>"510-555-9999")
        user.update(phone:'510-555-9999')
      end

      it "doesn't send call to update NationBuilder if no relevant field changed" do
        expect(NbPersonPushJob).not_to receive(:perform_later)
        user.update(phone:'510-555-1234')
      end
    end
  end
end
