require 'rails_helper'

describe Legislator do
  describe ".fetch_one" do
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

  describe ".fetch_all" do
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

  describe ".default_targets" do
    context "no args" do
      let(:rep) { FactoryGirl.create(:representative) }
      it "only returns top priority targets" do
        FactoryGirl.create(:target, legislator: rep, priority: 1)
        FactoryGirl.create(:rep_target)
        expect(Legislator.default_targets).to eq [rep]
      end

      it "returns 5 targets" do
        FactoryGirl.create(:campaign_with_reps, count: 6, priority: 1)
        expect(Legislator.default_targets.count).to eq 5
      end
    end
    context "with args" do
      let(:rep)     { FactoryGirl.create(:representative) }
      let(:senator) { FactoryGirl.create(:senator) }
      before do
        FactoryGirl.create(:target, legislator: rep, priority: 1)
        FactoryGirl.create(:target, legislator: senator, priority: 1)
        FactoryGirl.create(:rep_target, priority: 1)
      end
      it "returns given number of targets" do
        expect(Legislator.default_targets(count: 2).count).to eq 2
      end
      it "excludes single legislator" do
        expect(Legislator.default_targets(excluding: rep.id)).not_to include(rep)
        expect(Legislator.default_targets(excluding: rep.id).count).to eq 2
      end
      it "excludes multiple legislators" do
        expect(Legislator.default_targets(excluding: [rep.id, senator.id]).count).to eq 1
      end
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

  describe "#serializable_hash" do
    let(:senator) { FactoryGirl.create(:senator) }
    let(:keys) { keys = ["id", "chamber", "party", "state_rank", "name", "state_abbrev", "district_code"] }

    context "no args" do
      it "returns proper fields" do
        expect(senator.as_json.keys).to match_array keys
      end
    end

    context "with args" do
      it "returns proper fields" do
        expect(senator.as_json(extra_key: false).keys).to match_array(keys + [:extra_key])
      end
    end
  end
end