require 'rails_helper'

describe Integration::Sunlight do

  describe "#get_legislator" do
    context "district" do
      subject(:response) do
        Integration::Sunlight.get_legislator(state: 'CA', district: '13')
      end

      it "returns results count == 1" do 
        expect(response['results_count']).to eq 1
      end

      it "returns correct first name" do 
        expect(response['legislator']['first_name']).to eq 'Barbara'
      end

      it "returns correct last name" do 
        expect(response['legislator']['last_name']).to eq 'Lee'
      end

      it "returns correct phone number" do 
        expect(response['legislator']['phone']).to eq '202-225-2661'
      end

      it "returns bioguide id" do 
        expect(response['legislator']['bioguide_id']).to eq 'L000551'
      end

      it "doesn't return senate rank" do 
        expect(response['legislator']['state_rank']).to be_nil
      end
    end

    context "Senate" do
      subject(:response) do
        Integration::Sunlight.get_legislator(state: 'CA', senate_class: 1)
      end

      it "returns bioguide id" do 
        expect(response['legislator']['bioguide_id']).to eq 'F000062'
      end

      it "returns senate rank" do 
        expect(response['legislator']['state_rank']).to eq 'senior'
      end
    end

    context "Multiple results" do
      subject(:response) do
        Integration::Sunlight.get_legislator(state: 'VT')
      end

      it "returns results count > 1" do 
        expect(response['results_count']).to be > 0
      end
    end

    context "Not found" do
      subject(:response) do
        Integration::Sunlight.get_legislator(state: 'CA', district: 13, senate_class: 1)
      end

      it "returns results count == 0" do 
        expect(response['results_count']).to eq 0
      end
    end

    context "Bad key" do
      subject(:response) do
        Integration::Sunlight.get_legislator(state: 'badkey')
      end

      it "returns results count == nil" do 
        expect(response['results_count']).to be_nil
      end
    end
  end
end