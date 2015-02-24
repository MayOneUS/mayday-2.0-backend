require 'rails_helper'

describe ZipCode do
  describe "#target_legislators" do
    let(:state) { FactoryGirl.create(:state, abbrev: 'CA') }
    let(:district) { FactoryGirl.create(:district, state: state, district: '13') }
    let(:rep) { FactoryGirl.create(:representative, district: district) }
    let(:senator) { FactoryGirl.create(:senator, state: state) }
    let(:zip) { FactoryGirl.create(:zip_code, state: state, zip_code: '94703', city: 'Berkeley') }
    let(:campaign) { FactoryGirl.create(:campaign) }

    context "zip in one district, targeted" do
      before do
        campaign.legislators << rep
        zip.districts = [district]
      end

      it "returns the representative" do
        expect(zip.target_legislators).to eq [rep]
      end

      context "and senator is targeted" do
        before { campaign.legislators << senator }
        it "returns the senator and representative" do
          expect(zip.target_legislators).to match_array [rep, senator]
        end
      end
    end

    context "zip in one district, not targeted" do
      before do
        zip.districts = [FactoryGirl.create(:district)]
      end

      it "returns empty array" do
        expect(zip.target_legislators).to eq []
      end

      context "and senator is targeted" do
        before { campaign.legislators << senator }
        it "returns the senator" do
          expect(zip.target_legislators).to match_array [senator]
        end
      end
    end

    context "zip in multiple districts, including targeted district" do
      before do
        rep2 = FactoryGirl.create(:representative)
        campaign.legislators = [rep]
        zip.districts = [district, rep2.district]
      end

      it "returns empty array" do
        expect(zip.target_legislators).to eq []
      end

      context "and senator is targeted" do
        before { campaign.legislators << senator }
        it "returns the empty array" do
          expect(zip.target_legislators).to match_array []
        end
      end
    end

    context "zip in multiple districts, none targeted" do
      before do
        zip.districts = [FactoryGirl.create(:district), FactoryGirl.create(:district)]
      end

      it "returns empty array" do
        expect(zip.target_legislators).to eq []
      end
    end
  end
end