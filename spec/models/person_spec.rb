require 'rails_helper'

describe Person do
  let(:district) { FactoryGirl.create(:district) }
  let(:person)   { FactoryGirl.create(:person, district: district,
                                               state:    district.state,
                                               zip_code: '03431') }
  describe "#target_legislators" do
    let!(:campaign) { FactoryGirl.create(:campaign_with_reps, count: 6, priority: 1) }
    let!(:rep_with_us) { FactoryGirl.create(:representative, with_us: true, district: district) }
    let!(:unconvinced_senator) {FactoryGirl.create(:senator, with_us: false, state: district.state) }

    context "normal" do
      subject(:legislators) { person.target_legislators }

      it "returns local senator first" do
        expect(legislators.first).to eq unconvinced_senator
      end
      it "returns 5 legislators" do
        expect(legislators.count).to eq 5
      end
    end

    context "json" do
      subject(:legislators) { person.target_legislators(json: true) }
      
      it "returns local senator first" do
        expect(legislators.first['id']).to eq unconvinced_senator.id
      end
      it "sets local to true for local senator" do
        expect(legislators.first['local']).to be true
      end
      it "sets local to false for other targets" do
        expect(legislators.second['local']).to be false
      end
    end
  end
end