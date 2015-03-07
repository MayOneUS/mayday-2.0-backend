require 'rails_helper'

describe V1::PeopleController,  type: :controller do
  describe "POST create" do
    it "returns success" do
      user = instance_double("Person", id: 3)
      expect(Person).to receive(:create_or_update).
        with(email: 'user@example.com', tags: ['test']) { user }
      post :create, person: { email:'user@example.com', tags: ['test'] }
      json_response = JSON.parse(response.body)

      expect(response).to be_success
      expect(json_response).to have_key('id')
      expect(json_response['id']).to eq(3)
    end
  end

  describe "GET targets" do
    context "no params" do
      before { get :targets }

      it "returns error" do
        expect(assigns(:error)).to_not be_blank
      end
    end

    context "bad email" do
      before { get :targets, { email: 'bad' } }

      it "returns error" do
        expect(assigns(:error)).to_not be_blank
      end
    end

    context "good email" do
      context "no address" do
        context "new user" do

          it "returns address required" do
            get :targets, { email: 'user@example.com' }
            expect(assigns(:address_required)).to be true
          end

          it "doesn't update location" do
            expect_any_instance_of(Location).to receive(:update_location).
              with({}) { nil }

            get :targets, { email: 'user@example.com' }
          end

          it "sets target legislators" do
            rep = instance_double("Legislator")
            expect_any_instance_of(Person).to receive(:target_legislators).
              with(json: true) { [rep] }
            get :targets, { email: 'user@example.com' }
            expect(assigns(:target_legislators)).to eq [rep]
          end

        end

        context "existing user with address info" do

          before do
            FactoryGirl.create(:person, :with_district, email: 'user@example.com')
            get :targets, { email: 'user@example.com' }
          end

          it "returns address not required" do
            expect(assigns(:address_required)).to be false
          end

        end
      end

      context "good address" do

        it "updates location" do
          expect_any_instance_of(Location).to receive(:update_location).
            with(address: '2020 Oregon St', zip: '94703') { true }

          get :targets, email: 'user@example.com', address: '2020 Oregon St', zip: '94703'
        end

      end
    end
  end

end