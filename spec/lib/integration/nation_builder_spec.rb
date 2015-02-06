require 'rails_helper'

describe Integration::NationBuilder do

  before(:all) do
    @person_id = 57126
    @event_id = 5
  end

  describe "#query_people_by_email" do
    it "formats url for target endpoint" do
      expect(Integration::NationBuilder)
        .to receive(:request_handler)
        .with(endpoint_path: Integration::NationBuilder::ENDPOINTS[:people_by_email]%'dude@gmail.com')
        .and_call_original
      Integration::NationBuilder.query_people_by_email('dude@gmail.com')
    end
    it "responds with a parsed person_id" do
      response = Integration::NationBuilder.query_people_by_email('dude@gmail.com')
      expect(response).to eq(@person_id)
    end
  end

  describe "#create_or_update_person" do
    it "formats url for target endpoint" do
      body = {person: {'first_name' => 'Fred', 'email' => 'fred@email.com'}}
      expect(Integration::NationBuilder)
        .to receive(:request_handler)
        .with(endpoint_path: Integration::NationBuilder::ENDPOINTS[:people], body: body, method: 'put')
        .and_call_original
      Integration::NationBuilder.create_or_update_person(attributes: {first_name: 'Fred', email: 'fred@email.com'})
    end
    it "responds with a parsed person_id" do
      response = Integration::NationBuilder.create_or_update_person(attributes: {first_name: 'Fred'})
      expect(response).to eq(@person_id)
    end
  end

  describe "#create_rsvp" do
    it "formats url for target endpoint" do
      body = {'rsvp': {'person_id': @person_id}}
      expect(Integration::NationBuilder)
        .to receive(:request_handler)
        .with(endpoint_path: Integration::NationBuilder::ENDPOINTS[:rsvps_by_event]% @event_id,  body: body, method: 'post')
        .and_call_original
      Integration::NationBuilder.create_rsvp(event_id: @event_id, person_id: @person_id)
    end
    it "responds with a parsed rsvp_id" do
      response = Integration::NationBuilder.create_rsvp(event_id: @event_id, person_id: @person_id)
      expect(response).to eq(13)
    end
  end

  describe "#list_counts" do
    it "formats url for target endpoint" do
      expect(Integration::NationBuilder)
        .to receive(:request_handler)
        .with(endpoint_path: Integration::NationBuilder::ENDPOINTS[:lists])
        .and_call_original
      Integration::NationBuilder.list_counts
    end
    it "responds with a parsed list counts" do
      response = Integration::NationBuilder.list_counts
      expect(response).to include(supporter_count: 2812, volunteer_count: 43949)
    end
  end
end