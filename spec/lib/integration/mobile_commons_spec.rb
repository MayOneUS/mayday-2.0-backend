require 'rails_helper'

describe Integration::MobileCommons do
  describe "#district_from_coords" do
    context "good coords" do
      subject(:response) do
        Integration::MobileCommons.district_from_coords([35.75, 86.88])
      end

      it "returns correct state" do 
        expect(response[:state]).to eq 'CA'
      end

      it "returns correct district" do 
        expect(response[:district]).to eq '13'
      end
    end

    context "at-large district" do
      subject(:response) do
        Integration::MobileCommons.district_from_coords(['vt', 86.88])
      end

      it "returns correct state" do 
        expect(response[:state]).to eq 'VT'
      end

      it "returns district 0" do 
        expect(response[:district]).to eq '0'
      end
    end

    context "bad coords" do
      subject(:response) do
        Integration::MobileCommons.district_from_coords(['bad', 86.88])
      end

      it "doesn't return district" do 
        expect(response[:district]).to be_nil
      end

    end
  end
end