require 'rails_helper'

describe V1::PeopleController,  type: :controller do
  describe "POST create" do
    it "returns success" do
      user = instance_double("Person", id: 3, valid?: true)
      allow(Person).to receive(:create_or_update).and_return(user)

      post :create, person: { email: 'user@example.com', remote_fields: { tags: ['test'] } }
      json_response = JSON.parse(response.body)

      expect(Person).to have_received(:create_or_update)
        .with(email: 'user@example.com', remote_fields: { tags: ['test'] })
      expect(response).to be_success
      expect(json_response).to have_key('id')
      expect(json_response['id']).to eq(3)
    end

    it "returns error without params" do
      post :create
      json_response = JSON.parse(response.body)

      expect(json_response).to have_key('error')
      expect(json_response['error']).to eq("person is required")
    end
  end

  describe "GET targets" do

    context "with no params" do
      render_views
      it "returns error" do
        get :targets
        @json_response = JSON.parse(response.body)
        expect(@json_response).to have_key('error')
        expect(@json_response['error']).to eq("Email can't be blank. Phone can't be blank.")
      end
    end

    context "invalid email" do
      render_views
      it "returns error" do
        get :targets, { email: 'bad' }
        expect(assigns(:error)).to_not be_blank
      end
    end

    context "with good email" do
      context "with no address" do
        context "with new user" do
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
            # TODO In testing, if rendering views, there is a preformance loop when using as_json w/ jbuilder.
            rep = instance_double("Legislator")
            expect_any_instance_of(Person).to receive(:target_legislators).
              with(json: true).and_return([rep])
            get :targets, { email: 'user@example.com' }
            expect(assigns(:target_legislators)).to eq [rep]
          end
        end

        context "with existing user with address info" do
          render_views
          it "returns address not required" do
            FactoryGirl.create(:person, :with_district, email: 'user@example.com')
            get :targets, { email: 'user@example.com' }

            json_response = JSON.parse(response.body)
            expect(json_response['address_required']).to be false
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