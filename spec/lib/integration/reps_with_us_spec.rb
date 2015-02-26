require 'rails_helper'

describe Integration::MobileCommons do
  describe ".all_reps_with_us" do
    subject(:response) do
      Integration::RepsWithUs.all_reps_with_us
    end

    it "returns list of reps" do
      list = ["D000563", "B001230", "B000711", "W000817", "S001168", "B001279",
              "B001281", "K000382", "L000559", "L000570", "Y000062", "P000265",
              "B000574", "C001037", "C001080", "C001069", "W000808"]
      expect(response).to eq list
    end
  end

  describe ".rep_with_us?" do
    context "rep with us" do
      subject(:response) do
        Integration::RepsWithUs.rep_with_us?("S001168")
      end

      it "returns true" do
        expect(response).to be true
      end
    end

    context "unconvinced legislator" do
      subject(:response) do
        Integration::RepsWithUs.rep_with_us?("C001102")
      end

      it "returns false" do
        expect(response).to be false
      end
    end

    context "not found" do
      subject(:response) do
        Integration::RepsWithUs.rep_with_us?("bad")
      end

      it "returns nil" do
        expect(response).to be_nil
      end
    end
  end
end