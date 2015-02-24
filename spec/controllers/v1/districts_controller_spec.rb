require 'rails_helper'

describe V1::DistrictsController do
  describe "GET index" do
    let(:campaign) { FactoryGirl.create(:campaign) }
    let(:rep)      { FactoryGirl.create(:representative) }

    before do
        FactoryGirl.create(:target, legislator: rep, priority: 1, campaign: campaign)
    end

    context "no params" do
      before { get :index }

      it "sets address_required to true" do
        expect(assigns(:address_required)).to be true
      end
      it "assigns targets" do
        expect(assigns(:target_legislators)).to eq [rep]
      end
    end

    context "bad address" do
      before { get :index, { address: '2020 Oregon St', zip: 'bad' } }

      it "sets address_required to true" do
        expect(assigns(:address_required)).to be true
      end
      it "assigns targets" do
        expect(assigns(:target_legislators)).to eq [rep]
      end
    end

    context "good address, in target district" do
      let(:state)     { FactoryGirl.create(:state, abbrev: 'CA') }
      let(:district)  { FactoryGirl.create(:district, state: state, district: '13') }
      let(:local_rep) { FactoryGirl.create(:representative, district: district) }

      before do
        FactoryGirl.create(:target, legislator: local_rep, campaign: campaign, priority: 1)
        get :index, { address: '2020 Oregon St', zip: '94703' }
      end

      it "sets address_required to false" do
        expect(assigns(:address_required)).to be false
      end
      it "assigns district id" do
        expect(assigns(:district_id)).to be district.id
      end
      it "assigns targets" do
        reps = [local_rep.as_json(local: true), rep]
        expect(assigns(:target_legislators)).to eq reps
      end
    end

    context "zip only" do
      context "zip found, not targeted" do
        let!(:zip) { FactoryGirl.create(:zip_code, zip_code: '94703') }

        before { get :index, { zip: '94703' } }

        it "assigns zip code" do
          expect(assigns(:zip_code)).to eq zip
        end
        it "sets address_required to false" do
          expect(assigns(:address_required)).to eq false
        end
        it "assigns targets" do
          expect(assigns(:target_legislators)).to eq [rep]
        end
      end

      context "zip not found" do
        before { get :index, { zip: '99999' } }

        it "doesn't assign zip code" do
          expect(assigns(:zip_code)).to be_nil
        end
        it "sets address_required to true" do
          expect(assigns(:address_required)).to be true
        end
        it "assigns targets" do
          expect(assigns(:target_legislators)).to eq [rep]
        end
      end
    end
  end
end