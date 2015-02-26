require 'rails_helper'

describe V1::LegislatorsController do
  describe "GET index" do
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
      let!(:campaign) { FactoryGirl.create(:campaign_with_reps, count: 3, priority: 1) }
      let (:state)    { FactoryGirl.create(:state, abbrev: 'CA') }
      let (:district) { FactoryGirl.create(:district, district: '13', state: state) }
      let!(:senator)  { FactoryGirl.create(:senator, state: state, with_us: false) }
      let!(:rep)      { FactoryGirl.create(:representative, district: district,
                                                            with_us: true) }
      let(:campaign_ids) { campaign.legislators.pluck(:id) }
      let(:returned_ids) { assigns(:target_legislators).map{|tl| tl['id']} }

      context "no address" do
        context "new user" do
          before { get :index, { email: 'user@example.com' } }

          it "returns address required" do
            expect(assigns(:address_required)).to be true
          end

          it "returns correct targets" do
            expect(returned_ids).to eq campaign_ids
          end

          it "doesn't return local targets" do
            expect(assigns(:target_legislators).first['local']).to be false
          end
        end

        context "existing user with address info" do
          let!(:user) { FactoryGirl.create(:person, email: 'user@example.com',
                                                    district: district) }
          before { get :index, { email: 'user@example.com' } }

          it "returns address not required" do
            expect(assigns(:address_required)).to be false
          end

          it "returns correct targets" do
            expect(returned_ids).to eq [senator.id] + campaign_ids
          end

          it "sets local attribute for all targets" do
            locals = assigns(:target_legislators).map{|tl| tl['local']}
            expect(locals).to eq [true, false, false, false]
          end
        end
      end

      context "good address" do
        before do
          get :index, { email: 'user@example.com', address: '2020 Oregon St', zip: '94703' }
        end

        it "returns correct targets" do
          expect(returned_ids).to eq [senator.id] + campaign_ids
        end
      end
    end
  end
end