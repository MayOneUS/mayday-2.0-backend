class Integration::Sunlight

  DOMAIN = 'congress.api.sunlightfoundation.com'
  LEGISLATORS_ENDPOINT = '/legislators'
  RESULTS_KEY = 'results'
  RESULTS_COUNT_KEY = 'count'
  RELEVANT_KEYS = { bioguide_id: 'bioguide_id',
                    first_name:  'first_name',
                    last_name:   'last_name',
                    phone:       'phone',
                    senate_rank: 'state_rank' }

  def self.get_legislator(state:, district: nil, senate_class: nil)
    response = get_json(rep_url(state, district, senate_class))
    results_count = response[RESULTS_COUNT_KEY]
    results = response[RESULTS_KEY]
    output = { results_count: results_count }
    if results_count == 1
      legislator_hash = results.first
      RELEVANT_KEYS.each do |key, value|
        output[key] = legislator_hash[value]
      end
    end
    output
  end

  private

  def self.get_json(endpoint_query)
    JSON.parse(RestClient.get(endpoint_query))
  end

  def self.rep_url(state, district, senate_class)
    query_string = {
      apikey:       ENV['SUNLIGHT_KEY'],
      state:        state,
      district:     district,
      senate_class: senate_class
    }.to_query

    ['http://', DOMAIN, LEGISLATORS_ENDPOINT, '?', query_string].join
  end

end