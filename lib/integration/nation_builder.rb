class Integration::NationBuilder

  STANDARD_HEADERS = {'Accept' => 'application/json', 'Content-Type' => 'application/json'}
  ENDPOINTS = {
    list_count_page: '/supporter_counts_for_website',
    people:          '/api/v1/people/push',
    people_by_email: '/api/v1/people/match?email=%s',
    rsvps_by_event:  '/api/v1/sites/mayday/pages/events/%s/rsvps'
  }
  ALLOWED_PARAMS_PERSON = %w[birthdate do_not_call first_name last_name email email_opt_in employer is_volunteer mobile_opt_in
    mobile occupation phone primary_address recruiter_id sex tags request_ip skills rootstrikers_subscription uuid
    pledge_page_slug fundraising email subscription maydayin30_entry_url voting_district_id map_lookup_district]

  def self.query_people_by_email(email)
    rescue_oauth_errors do
      response = request_handler(endpoint_path: ENDPOINTS[:people_by_email] % email)
      response['person']
    end
  end

  def self.create_person_and_rsvp(event_id:, person_attributes: {}, person_id: nil)
    raise ArgumentError, ':mising person_id or :person_attributes' if person_id.blank? && (person_attributes.nil? || person_attributes.empty?)
    person_id ||= create_or_update_person(attributes: person_attributes)['id']
    create_rsvp(event_id: event_id, person_id: person_id)
  end

  def self.create_or_update_person(attributes:)
    rescue_oauth_errors do
      body = {'person': parse_person_attributes(attributes)}
      response = request_handler(endpoint_path: ENDPOINTS[:people], body: body, method: 'put')
      response['person']
    end
  end

  def self.create_rsvp(event_id:, person_id:)
    rescue_oauth_errors do
      body = {'rsvp': {'person_id': person_id}}
      response = request_handler(endpoint_path: ENDPOINTS[:rsvps_by_event] % event_id, body: body, method: 'post')
      response['rsvp']
    end
  end

  # Public: fetches list coutns from a fake NB page with json on it.
  # Nationbuilder page template is only this:
  # {"supporter_count": {{ settings.supporters_count }}, "volunteer_count": {{ settings.volunteers_count }} }
  def self.list_counts
    target_page = ENV['NATION_BUILDER_DOMAIN'] + ENDPOINTS[:list_count_page]
    JSON.parse(RestClient.get(target_page)).symbolize_keys
  end

  private

  def self.request_handler(method: 'get', endpoint_path:, body: {})
    response = token.send(method, endpoint_path, body: body.to_json, headers: STANDARD_HEADERS)
    JSON.parse(response.body)
  end

  def self.rescue_oauth_errors
    begin
      yield
    rescue OAuth2::Error => e
      if e.response.parsed['code'] == 'no_matches'
        nil
      elsif e.response.parsed['code'] == 'validation_failed'
        e.response.parsed['validation_errors'][0]
      else
        puts e.inspect
        e.response.parsed['message']
      end
    end
  end

  def self.client
    @@client ||= OAuth2::Client.new(ENV['NATION_BUILDER_ID'], ENV['NATION_BUILDER_SECRET'], site: 'https://'+ENV['NATION_BUILDER_DOMAIN'])
  end

  def self.token
    @@token ||= OAuth2::AccessToken.new(client, ENV['NATION_BUILDER_API_TOKEN'])
  end

  def self.parse_person_attributes(raw_parameters)
    parameters = ActionController::Parameters.new(raw_parameters)
    parameters.permit(ALLOWED_PARAMS_PERSON)
  end

end