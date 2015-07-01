require 'rails_helper'

describe V1::PeopleController,  type: :controller do
  describe "POST create" do
    render_views
    context "with valid params" do
      it "returns person" do
        user = FactoryGirl.create(:person, email: 'user@example.com')
        allow(Person).to receive(:create_or_update).and_return(user)

        post :create, person: { email: 'user@example.com', remote_fields: { tags: ['test'] } }
        json_response = JSON.parse(response.body)

        expect(Person).to have_received(:create_or_update)
          .with(email: 'user@example.com', remote_fields: { tags: ['test'] })
        expect(response).to be_success
        expect(json_response).to have_key('uuid')
        expect(json_response['uuid']).not_to be_blank
      end
      it "marks activities completed" do
        FactoryGirl.create(:activity, template_id: 'real_id')
        FactoryGirl.create(:activity, template_id: 'other_id')
        post :create, person: { email: 'user@example.com' }, actions: ['real_id', 'other_id']
        json_response = JSON.parse(response.body)
        expect(response).to be_success
        expect(json_response).to have_key('completed_activities')
        expect(json_response['completed_activities']).to match_array ['real_id', 'other_id']
      end
    end
    context "without params" do
      it "returns error" do
        post :create
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key('error')
        expect(json_response['error']).to eq("person is required")
      end
    end
  end
  describe "GET show" do
    render_views
    context "with good params" do
      it "returns person object" do
        FactoryGirl.create(:person, uuid: 'the-uuid', email: 'joe@example.com')
        get :show, identifier: 'joe@example.com'
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.slice('uuid', 'activities').values)
          .to eq ['the-uuid', []]
      end
    end
  end

  describe "GET targets" do

    context "with no params" do
      render_views
      it "returns error" do
        get :targets
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('error')
        expect(json_response['error']).to eq("person is required")
      end
    end

    context "invalid email" do
      render_views
      it "returns error" do
        get :targets, person: { email: 'bad' }
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('errors')
        expect(json_response['errors']).to eq("Email is invalid.")
      end
    end

    context "with good email" do
      render_views
      context "with no address" do
        context "with new user" do

          it "returns address required" do
            get :targets, person: { email: Faker::Internet.email }
            json_response = JSON.parse(response.body)
            expect(json_response['address_required']).to eq(true)
          end

          it "doesn't update location" do
            expect_any_instance_of(Location).not_to receive(:update_location)

            get :targets, person: { email: 'user@example.com' }
          end

          it "sets target legislators" do
            # TODO In testing, if rendering views, there is a preformance loop when using as_json w/ jbuilder.
            # rep = instance_double("Legislator")
            # expect_any_instance_of(Person).to receive(:target_legislators).
            #   with(json: true).and_return([rep])
            # get :targets, person: { email: 'user@example.com' }
            # json_response = JSON.parse(response.body)
            # expect(json_response['target_legislators'][0]['description']).to eq "Legislator (instance)"
          end
        end

        context "with existing user with address info" do
          it "returns address not required" do
            FactoryGirl.create(:person, :with_district, email: 'user@example.com')
            get :targets, person: { email: 'user@example.com' }

            json_response = JSON.parse(response.body)
            expect(json_response['address_required']).to be false
          end
        end

      end

      context "good address" do

        it "updates location" do
          expect_any_instance_of(Location).to receive(:update_location).
            with( {address: '2020 Oregon St', zip: '94703'}) { true }

          get :targets, person: {email: Faker::Internet.email, address: '2020 Oregon St', zip: '94703'}
        end

      end
    end
  end

end