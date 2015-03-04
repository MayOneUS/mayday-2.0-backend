require 'rails_helper'

describe V1::EventsController,  type: :controller do

  describe "GET index" do
    it "returns success" do
      get :index
      expect(response).to be_success
    end
    it "sets the events variable" do
      event = instance_double("Event")
      expect(Event).to receive(:upcoming_events) { [event] }
      get :index
      expect(assigns(:events)).to eq [event]
    end
  end

  describe "POST create_rsvp" do
    context "with a person in parameters" do
      it "returns success" do
        post :create_rsvp, event_id: 5, person: {email: 'dude@gmail.com'}
        expect(response).to be_success
      end
    end

    context "with a person_id in parameters" do
      it "returns success" do
        post :create_rsvp, event_id: 5, person_id: 10
        expect(response).to be_success
      end
    end

    context "with a person in parameters" do
      it "returns success" do
        post :create_rsvp, event_id: 5
        expect(response).not_to be_success
        expect(JSON.parse(response.body)).to have_key('error')
      end
    end

  end

end