require 'rails_helper'

describe Integration::Sunlight do

  describe "#get_bill" do
    context "with good params" do
      subject(:response) do
        Integration::Sunlight.get_bill(bill_id: 's1016-114')
      end

      it "returns basic bill info" do
        keys   = %w[bill_id chamber sponsor_id]
        values = %w[s1016-114 senate J000293]
        expect(response.slice(*keys).values).to eq values
      end

      it "renames fields" do
        keys   = %w[congressional_session introduced_at opencongress_url]
        values = [114, '2015-04-20', 'https://www.opencongress.org/bill/s1016-114']
        expect(response.slice(*keys).values).to eq values
      end

      it "parses associations" do
        keys = %w[cosponsored_at sponsor_id]
        expect(response['cosponsors'].length).to eq 30
        expect(response['cosponsors'].first.keys).to eq keys
      end
    end

    context "not found" do
      subject(:response) do
        Integration::Sunlight.get_bill(bill_id: 'not_found')
      end

      it "returns no results" do
        expect(response).to be_nil
      end
    end
  end

  describe "#fetch_legislators" do
    context "district" do
      subject(:legislator) do
        query_params = {state: 'CA', district: '13'}
        Integration::Sunlight.fetch_legislator(query_params: query_params)
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
        query_params = {state: 'CA', senate_class: 1}
        Integration::Sunlight.fetch_legislator(query_params: query_params)
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
  end

  describe "#fetch_legislators" do

    subject(:legislators) do
      Integration::Sunlight.fetch_legislators
    end

    it "returns correct number of legislators" do
      expect(legislators.length).to eq 6
    end

    context "multiple results" do
      subject(:legislators) do
        query_params = {state: 'CA'}
        Integration::Sunlight.fetch_legislators(query_params: query_params)
      end

      it "returns results count > 1" do
        expect(legislators.length).to be > 0
      end

      it "returns correct number of legislators" do
        expect(legislators.length).to eq 6
      end
    end

    context "not found" do
      subject(:legislators) do
        query_params = {state: 'not_found'}
        Integration::Sunlight.fetch_legislators(query_params: query_params)
      end

      it "returns results count == 0" do
        expect(legislators.length).to eq 0
      end
    end

    context "bad key" do
      subject(:response) do
        query_params = {state: 'bad_key'}
        Integration::Sunlight.fetch_legislators(query_params: query_params)
      end

      it "returns no results" do
        expect(response).to be_nil
      end
    end
  end
end