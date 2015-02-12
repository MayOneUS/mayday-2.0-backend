require 'rails_helper'

describe V1::DistrictsController do
  describe "GET index" do

    context "no params" do
      before { get :index }

      it "returns success" do
        expect(response).to be_success
      end

      it "returns error message" do
        expect(parsed(response)['error']).to be_truthy
      end
    end

    context "good address, not in campaign" do
      before do
        FactoryGirl.create(:campaign)
        state = FactoryGirl.create(:state, abbrev: 'CA')
        FactoryGirl.create(:district, state: state, district: '13')
      end

        get :index, { address: '2020 Oregon St', zip: '94703' }
      end
      
      it "returns success" do
        expect(response).to be_success
      end

      it "returns district" do
        expect(parsed(response)['district']).to eq '13'
      end

      it "returns state" do
        expect(parsed(response)['state']).to eq 'CA'
      end

      it "returns address" do
        expect(parsed(response)['address']).to match /2020 Oregon St.* Berkeley/
      end

      it "returns targeted == false" do
        expect(parsed(response)['targeted']).to be false
      end
    end

    context "good address, in campaign" do
      it "returns targeted == true" do
        state = FactoryGirl.create(:state, abbrev: 'CA')
        district = FactoryGirl.create(:district, state: state, district: '13')
        campaign = FactoryGirl.create(:campaign)
        campaign.districts = [district]
        get :index, { address: '2020 Oregon St', zip: '94703' }
        
        expect(parsed(response)['targeted']).to be true
      end
    end

    context "zip only" do
      let (:state) { FactoryGirl.create(:state, abbrev: 'CA') }
      let (:district) { FactoryGirl.create(:district, state: state, district: '13') }
      let (:zip) { FactoryGirl.create(:zip_code, state: state, zip_code: '94703', city: 'Berkeley') }
      let (:campaign) { FactoryGirl.create(:campaign) }

      before { campaign.districts = [district] }

      context "zip in one district, targeted" do
        before do
          zip.districts = [district]
          get :index, { zip: '94703' }
        end
      
        it "returns success" do
          expect(response).to be_success
        end

        it "returns district" do
          expect(parsed(response)['district']).to eq '13'
        end

        it "returns state" do
          expect(parsed(response)['state']).to eq 'CA'
        end

        it "returns targeted" do
          expect(parsed(response)['targeted']).to be true
        end
      end

      context "zip in one district, not targeted" do
        before do
          zip.districts = [FactoryGirl.create(:district)]
          get :index, { zip: '94703' }
        end

        it "returns not targeted" do
          expect(parsed(response)['targeted']).to be_falsey
        end
      end

      context "zip in multiple districts, including targeted district" do
        before do
          zip.districts = [district, FactoryGirl.create(:district)]
          get :index, { zip: '94703' }
        end

        it "returns city" do
          expect(parsed(response)['city']).to eq 'Berkeley'
        end

        it "returns state" do
          expect(parsed(response)['state']).to eq 'CA'
        end

        it "returns targeted == nil" do
          expect(parsed(response)['targeted']).to be_falsey
        end
      end

      context "zip in multiple districts, none targeted" do
        before do
          zip.districts = [FactoryGirl.create(:district), FactoryGirl.create(:district)]
          get :index, { zip: '94703' }
        end

        it "returns targeted == false" do
          expect(parsed(response)['targeted']).to be_falsey
        end
      end

      context "zip not found" do
        before do
          get :index, { zip: '99999' }
        end

        it "returns targeted == nil" do
          expect(parsed(response)['targeted']).to be_falsey
        end

        it "returns state == nil" do
          expect(parsed(response)['state']).to be_nil
        end

        it "returns city == nil" do
          expect(parsed(response)['city']).to be_nil
        end
      end
    end
  end
end

def parsed(response)
  JSON.parse(response.body)
end