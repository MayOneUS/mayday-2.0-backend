require 'rails_helper'

describe District do
  describe ".find_by_address" do
    let(:state) { FactoryGirl.create(:state, abbrev: 'CA') }
    let!(:district) { FactoryGirl.create(:district, district: '13', state: state) }
    
    subject(:result) do
      District.find_by_address(address: '123 Main St', zip: '94703')
    end

    it "finds district" do
      expect(result).to eq district
    end
  end

  describe "#fetch_rep" do
    let(:state) { FactoryGirl.create(:state, abbrev: 'CA') }
    let(:district) { FactoryGirl.create(:district, district: '13', state: state) }
    subject(:rep) { district.fetch_rep }

    it "associates rep with correct district" do
      expect(rep.district).to eq district
    end
  end

  describe "#target_legislators" do
    let(:state) { FactoryGirl.create(:state, abbrev: 'CA') }
    let(:district) { FactoryGirl.create(:district, state: state, district: '13') }
    let(:rep) { FactoryGirl.create(:representative, district: district) }
    let(:senator) { FactoryGirl.create(:senator, state: state) }
    let(:campaign) { FactoryGirl.create(:campaign) }

    context "district targeted" do
      before { campaign.legislators << rep }

      it "returns the representative" do
        expect(district.target_legislators).to eq [rep]
      end

      context "and senator is targeted" do
        before { campaign.legislators << senator }

        it "returns the senator and representative" do
          expect(district.target_legislators).to match_array [rep, senator]
        end
      end
    end

    context "district not targeted" do
      before { campaign.legislators << FactoryGirl.create(:representative) }

      it "returns empty array" do
        expect(district.target_legislators).to eq []
      end

      context "and senator is targeted" do
        before { campaign.legislators << senator }
        it "returns the senator" do
          expect(district.target_legislators).to match_array [senator]
        end
      end
    end
  end
end