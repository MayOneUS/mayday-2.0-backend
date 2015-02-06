class Integration::NationBuilder

  STANDARD_HEADERS = {'Accept' => 'application/json', 'Content-Type' => 'application/json'}
  ENDPOINTS = {
    lists:           '/api/v1/lists/?per_page=100', #100 is max
    people:          '/api/v1/people/push',
    people_by_email: '/api/v1/people/match?email=%s',
    rsvps_by_event:  '/api/v1/sites/mayday/pages/events/%s/rsvps'
  }

  def self.query_people_by_email(email)
    rescue_oauth_errors do
      response = request_handler(endpoint_path: ENDPOINTS[:people_by_email] % email)
      response['person']['id']
    end
  end

  def self.create_or_update_person(attributes:)
    rescue_oauth_errors do
      body = {'person': attributes.stringify_keys}
      response = request_handler(endpoint_path: ENDPOINTS[:people], body: body, method: 'put')
      response['person']['id']
    end
  end

  def self.create_rsvp(event_id:, person_id:)
    rescue_oauth_errors do
      body = {'rsvp': {'person_id': person_id}}
      response = request_handler(endpoint_path: ENDPOINTS[:rsvps_by_event] % event_id, body: body, method: 'post')
      response['rsvp']['id']
    end
  end

  def self.list_counts
    rescue_oauth_errors do
      response = request_handler(endpoint_path: ENDPOINTS[:lists])
      list_ids = eval(ENV['NATION_BUILDER_LIST_IDS'])
      target_lists = response['results'].select{|list| list_ids.values.include?(list['id']) }
      target_lists.each_with_object({}) do |list, hash|
        hash_key = list_ids.invert[list['id']]
        hash[hash_key] = list['count']
      end
    end
  end

  private

  def self.request_handler(method: 'get', endpoint_path:, body: {})
    # puts "endpoint_path: #{endpoint_path}"
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
        byebug
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

end