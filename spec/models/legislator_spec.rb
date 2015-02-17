require 'rails_helper'

describe Legislator do
  describe "#fetch_one" do
    context "by district" do
      let(:state) { FactoryGirl.create(:state, abbrev: 'CA') }
      let(:district) { FactoryGirl.create(:district, district: '13', state: state) }
      subject(:new_rep) { Legislator.fetch_one(district: district) }

      it "returns correct bioguide_id" do
        expect(new_rep.bioguide_id).to eq 'L000551'
      end

      it "returns state == nil" do
        expect(new_rep.state).to be_nil
      end

      it "associates rep with correct district" do
        expect(new_rep.district).to eq district
      end
    end

    context "by state and senate_class" do
      let(:state) { FactoryGirl.create(:state, abbrev: 'CA') }
      subject(:new_senator) { Legislator.fetch_one(state: state, senate_class: 1) }

      it "returns correct bioguide_id" do
        expect(new_senator.bioguide_id).to eq 'F000062'
      end

      it "returns district == nil" do
        expect(new_senator.district).to be_nil
      end

      it "associates senator with correct state" do
        expect(new_senator.state).to eq state
      end
    end

    context "not found" do
      let(:state) { FactoryGirl.create(:state, abbrev: 'not_found') }
      subject(:new_rep) { Legislator.fetch_one(state: state) }

      it "returns nil" do
        expect(new_rep).to be_nil
      end
    end
  end

  describe "#fetch_all" do
    before do
      state = FactoryGirl.create(:state, abbrev: 'CA')
      [11, 25, 31, 33, 35, 45].each do |district|
        FactoryGirl.create(:district, state: state, district: district)
      end
      Legislator.fetch_all
    end

    it "creates correct number of legislators" do
      expect(Legislator.count).to eq 6
    end
  end

  describe "#refetch" do
    let(:state) { FactoryGirl.create(:state, abbrev: 'CA') }
    subject(:senator) { Legislator.fetch_one(state: state, senate_class: 1) }
    before do
      senator.first_name = 'foo'
      senator.refetch
    end

    it "returns correct name" do
      expect(senator.first_name).to eq 'Dianne'
    end
  end
end