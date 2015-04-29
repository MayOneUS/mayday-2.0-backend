require 'rails_helper'

describe V1::LegislatorsController do
  describe "GET targeted" do
    it "returns a hash with a targeted legislator" do
      legislator = FactoryGirl.create(:representative, :targeted)

      get :targeted
      json_response = JSON.parse(response.body)

      expect(json_response[0]['name']).to eq(legislator.name)
    end
  end

  describe "GET show" do
    it "returns basic info" do
      legislator = FactoryGirl.create(:representative, :targeted)

      get :show, bioguide_id: legislator.bioguide_id
      json_response = JSON.parse(response.body)

      expect(json_response['name']).to eq(legislator.name)
    end
  end
end