require 'rails_helper'

describe Integration::NationBuilder do

  before(:all) do
    @person_id = 57126
    @event_id = 5
    @rsvp_id = 13
  end

  describe "#query_people_by_email" do
    it "formats url for target endpoint" do
      allow(Integration::NationBuilder).to receive(:request_handler).and_call_original

      Integration::NationBuilder.query_people_by_email('dude@gmail.com')

      expect(Integration::NationBuilder).to have_received(:request_handler)
        .with(endpoint_path: Integration::NationBuilder::ENDPOINTS[:people_by_email] % 'dude@gmail.com')
    end
    it "responds with a parsed person_id" do
      response = Integration::NationBuilder.query_people_by_email('dude@gmail.com')
      expect(response).to have_key('id')
      expect(response['id']).to eq(@person_id)
    end
  end

  describe "#create_person_and_rsvp" do
    it "should call proper methods" do
      person_attributes = {'first_name' => 'Fred', 'email' => 'fred@email.com'}
      allow(Integration::NationBuilder).to receive(:create_or_update_person).and_call_original
      allow(Integration::NationBuilder).to receive(:create_rsvp)

      Integration::NationBuilder.create_person_and_rsvp(person_attributes: person_attributes, event_id: @event_id)

      expect(Integration::NationBuilder).to have_received(:create_or_update_person)
      expect(Integration::NationBuilder).to have_received(:create_rsvp)
    end
  end

  describe "#create_or_update_person" do
    it "formats url for target endpoint" do
      body = {person: {'first_name' => 'Fred', 'email' => 'fred@email.com'}}
      allow(Integration::NationBuilder).to receive(:request_handler).and_call_original

      Integration::NationBuilder.create_or_update_person(attributes: {first_name: 'Fred', email: 'fred@email.com'})

      expect(Integration::NationBuilder).to have_received(:request_handler)
        .with(endpoint_path: Integration::NationBuilder::ENDPOINTS[:people], body: body, method: 'put')
    end
    it "responds with a parsed person_id" do
      response = Integration::NationBuilder.create_or_update_person(attributes: {first_name: 'Fred'})
      expect(response).to have_key('id')
      expect(response['id']).to eq(@person_id)
    end
  end

  describe "#create_rsvp" do
    it "formats url for target endpoint" do
      body = {'rsvp': {'person_id': @person_id}}
      allow(Integration::NationBuilder).to receive(:request_handler).and_call_original

      Integration::NationBuilder.create_rsvp(event_id: @event_id, person_id: @person_id)

      expect(Integration::NationBuilder).to have_received(:request_handler)
        .with(endpoint_path: Integration::NationBuilder::ENDPOINTS[:rsvps_by_event] % @event_id,  body: body, method: 'post')
    end
    it "responds with a parsed rsvp_id" do
      response = Integration::NationBuilder.create_rsvp(event_id: @event_id, person_id: @person_id)
      expect(response).to have_key('id')
      expect(response['id']).to eq(@rsvp_id)
    end
  end

  describe "#list_counts" do
    it "formats url for target endpoint" do
      allow(Integration::NationBuilder).to receive(:request_handler).and_call_original

      Integration::NationBuilder.list_counts

      expect(Integration::NationBuilder).to have_received(:request_handler).with(endpoint_path: Integration::NationBuilder::ENDPOINTS[:lists])

    end
    it "responds with a parsed list counts" do
      response = Integration::NationBuilder.list_counts
      expect(response).to include(supporter_count: 2812, volunteer_count: 43949)
    end
  end

  describe "#parse_person_attributes" do
    it "should handle allowed params" do
      sample_attributes = {first_name: 'Fred', email: 'dude@gmail.com', bad_param: 'bad'}

      parsed_attributed = Integration::NationBuilder.__send__(:parse_person_attributes, sample_attributes)

      expect(parsed_attributed).not_to have_key(:bad_param)
      expect(parsed_attributed).to have_key(:first_name)
    end
  end
end