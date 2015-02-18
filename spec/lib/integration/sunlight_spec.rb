require 'rails_helper'

describe Integration::Sunlight do

  describe "#get_legislators" do
    context "district" do
      subject(:response) do
        Integration::Sunlight.get_legislators(state: 'CA', district: '13')
      end
      subject(:legislator) { response['legislators'].first }

      it "returns results count == 1" do 
        expect(response['results_count']).to eq 1
      end

      it "returns correct first name" do 
        expect(legislator['first_name']).to eq 'Barbara'
      end

      it "returns correct last name" do 
        expect(legislator['last_name']).to eq 'Lee'
      end

      it "returns correct phone number" do 
        expect(legislator['phone']).to eq '202-225-2661'
      end

      it "returns district_code" do 
        expect(legislator['district_code']).to eq 13
      end

      it "returns bioguide id" do 
        expect(legislator['bioguide_id']).to eq 'L000551'
      end

      it "doesn't return senate rank" do 
        expect(legislator['state_rank']).to be_nil
      end
    end

    context "senate" do
      subject(:legislator) do
        response = Integration::Sunlight.get_legislators(state: 'CA',
                                                        senate_class: 1)
        response['legislators'].first
      end

      it "returns senate rank" do 
        expect(legislator['state_rank']).to eq 'senior'
      end

      it "returns state_abbrev" do 
        expect(legislator['state_abbrev']).to eq 'CA'
      end

      it "doesn't return district_code" do 
        expect(legislator['district_code']).to be_nil
      end
    end

    context "get all" do
      subject(:response) do
        Integration::Sunlight.get_legislators(get_all: true)
      end

      it "returns correct number of legislators" do 
        expect(response['legislators'].count).to eq 6
      end
    end

    context "multiple results" do
      subject(:response) do
        Integration::Sunlight.get_legislators(state: 'VT')
      end

      it "returns results count > 1" do 
        expect(response['results_count']).to be > 0
      end

      it "returns correct number of legislators" do 
        expect(response['legislators'].count).to eq 3
      end
    end

    context "not found" do
      subject(:response) do
        Integration::Sunlight.get_legislators(state: 'not_found')
      end

      it "returns results count == 0" do 
        expect(response['results_count']).to eq 0
      end
    end

    context "bad key" do
      subject(:response) do
        Integration::Sunlight.get_legislators(state: 'bad_key')
      end

      it "returns results count == nil" do 
        expect(response['results_count']).to be_nil
      end
    end
  end
end