require 'rails_helper'

describe Legislator do
  describe "#fetch" do
    context "fetch rep by state & district" do
      let(:state) { FactoryGirl.create(:state, abbrev: 'CA') }
      let(:district) { FactoryGirl.create(:district, district: '13', state: state) }
      subject(:new_rep) { Legislator.fetch(district: district) }

      it "returns correct bioguide_id" do
        expect(new_rep.bioguide_id).to eq 'L000551'
      end

      it "associates rep with correct state" do
        expect(new_rep.state).to eq state
      end

      it "associates rep with correct district" do
        expect(new_rep.district).to eq district
      end
    end
  end
end