require 'rails_helper'

describe V1::EventsController,  type: :controller do


  describe "POST create_rsvp" do
    it "returns success" do
      post :create_rsvp, event_id: 5, person: {email: 'dude@gmail.com'}
      expect(response).to be_success
    end
  end

end