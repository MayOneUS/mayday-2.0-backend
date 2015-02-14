class Integration::Here

  DOMAIN = 'geocoder.cit.api.here.com'
  GEOCODER_ENDPOINT = '/6.2/geocode.json?gen=6'

  def self.geocode_address(address: nil, city: nil, state: nil, zip: nil)
    response = get_json(geocoder_url(address, city, state, zip))
    address_name, coordinates, confidence = parse_response(response)

    { address:     address_name,
      coordinates: coordinates,
      confidence:  confidence }
  end

  private

  def self.geocoder_url(address, city, state, zip)
    query_string = {
      app_id: ENV['HERE_ID'],
      app_code: ENV['HERE_CODE'],
      searchtext: address,
      city: city,
      state: state,
      postalcode: zip
    }.to_query

    ['http://', DOMAIN, GEOCODER_ENDPOINT, '&', query_string].join
  end

  def self.get_json(endpoint_query)
    JSON.parse(RestClient.get(endpoint_query))
  end

  def self.parse_response(response)
    address_name, coordinates, confidence = nil
    if result = response['Response']['View'].first.try(:fetch, 'Result').try(:first)
      location = result['Location'] || {}
      coords = location['DisplayPosition'] || {}
      address_name = location['Address'].try(:fetch, 'Label')
      coordinates  = [ coords['Latitude'], coords['Longitude'] ]
      confidence = result['Relevance']
    end
    [ address_name, coordinates, confidence ]
  end
end