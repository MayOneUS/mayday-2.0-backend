require 'rails_helper'

describe V1::EventsController,  type: :controller do

  describe "GET index" do
    it "returns success" do
      get :index
      expect(response).to be_success
    end
    it "sets the events variable" do
      event = instance_double("Event")
      expect(Event).to receive(:upcoming) { [event] }
      get :index
      expect(assigns(:events)).to eq [event]
    end
  end

  describe "POST create_rsvp" do
    before do
      FactoryGirl.create(:activity, template_id: 'attend-event')
    end
    context "with a person in parameters" do
      it "returns success" do
        post :create_rsvp, event_id: 5, person: {email: 'dude@gmail.com'}
        expect(response).to be_success
      end
    end
    it "stores an action with the right params" do
      target_phone = '1-123-123-1234'
      person = FactoryGirl.build(:person)
      allow(person).to receive(:create_action)
      allow(Person).to receive_message_chain(:create_or_update).and_return(person)

      activity = Activity.new(template_id: Activity::DEFAULT_TEMPLATE_IDS[:rsvp])
      post_params = {
        utm_source: 'expected_source',
        utm_medium: 'expected_medium',
        utm_campaign: 'expected_campaign',
        source_url: 'expected_url'
      }

      expected_params = {template_id: Activity::DEFAULT_TEMPLATE_IDS[:rsvp]}.merge(post_params)
      post :create_rsvp, {person: {email: person.email}}.merge(post_params)
      expect(person).to have_received(:create_action).with(expected_params)
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