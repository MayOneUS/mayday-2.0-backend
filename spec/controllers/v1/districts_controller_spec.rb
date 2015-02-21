require 'rails_helper'

describe V1::DistrictsController do
  describe "GET index" do

    context "no params" do
      it "doesn't set zip code" do
        get :index
        expect(assigns(:zip_code)).to be_nil
      end
    end

    context "bad address" do
      it "doesn't assign district" do
        get :index, { address: '2020 Oregon St', zip: 'bad' }
        expect(assigns(:district)).to be_nil
      end
    end

    context "good address" do
      let (:state)    { FactoryGirl.create(:state, abbrev: 'CA') }
      let!(:district) { FactoryGirl.create(:district, state: state, district: '13') }

      before { get :index, { address: '2020 Oregon St', zip: '94703' } }

      it "assigns district" do
        expect(assigns(:district)).to eq district
      end
      it "assigns results instance variable" do
        expect(assigns(:results)).to be_a Hash
      end
    end

    context "zip only" do
      context "zip found" do
        let!(:zip) { FactoryGirl.create(:zip_code, zip_code: '94703') }

        it "sets zip code" do
          get :index, { zip: '94703' }
          expect(assigns(:zip_code)).to eq zip
        end
      end

      context "zip not found" do
        it "doesn't set zip code" do
          get :index, { zip: '99999' }
          expect(assigns(:zip_code)).to be_nil
        end
      end
    end
  end
end