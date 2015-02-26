require 'rails_helper'

describe V1::LegislatorsController do
  describe "GET index" do
    let(:campaign) { FactoryGirl.create(:campaign) }
    let(:rep)      { FactoryGirl.create(:representative) }

    context "no params" do
      before { get :index }

      it "returns error" do
        expect(assigns(:error)).to_not be_blank
      end
    end

    context "bad email" do
      before { get :index, { email: 'bad' } }

      it "returns error" do
        expect(assigns(:error)).to_not be_blank
      end
    end

    context "good email" do
      context "new user" do
        before { get :index, { email: 'user@example.com' } }

        it "returns valid user" do
          expect(assigns(:user).valid?).to be true
        end

        it "sets user email" do
          expect(assigns(:user).email).to eq 'user@example.com'
        end
      end

      context "existing user" do
        let!(:user) { FactoryGirl.create(:person, email: 'user@example.com') }
        before { get :index, { email: 'user@example.com' } }

        it "returns correct user" do
          expect(assigns(:user)).to eq user
        end
      end
    end

    context "good email and address" do
      let (:state)    { FactoryGirl.create(:state, abbrev: 'CA') }
      let!(:district) { FactoryGirl.create(:district, district: '13', state: state) }
      
      before do
        get :index, { email: 'user@example.com', address: '2020 Oregon St', zip: '94703' }
      end

      it "assigns proper district to user" do
        expect(assigns(:user).district).to eq district
      end
    end
  end
end