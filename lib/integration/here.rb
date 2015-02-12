class Integration::Here

  DOMAIN = 'geocoder.cit.api.here.com'
  GEOCODER_PATH = '/6.2/geocode.json?gen=6'
  AUTH_PARAMS = 'app_id=%s&app_code=%s'
  SEARCH_PARAMS = 'searchtext=%s&city=%s&state=%s&postalcode=%s'

  def self.geocode_address(address: nil, city: nil, state: nil, zip: nil)
    response = get_json(geocoder_url(address, city, state, zip))
    address_name, coordinates, confidence = parse_response(response)

    { address:     address_name,
      coordinates: coordinates,
      confidence:  confidence }
  end

  private

    def self.geocoder_url(address, city, state, zip)
      [ 'http://' + DOMAIN + GEOCODER_PATH,
        AUTH_PARAMS % [ ENV['HERE_ID'], ENV['HERE_CODE'] ],
        SEARCH_PARAMS % [address, city, state, zip]
      ].join('&')
    end

    def self.get_json(address)
      JSON.parse(RestClient.get(address))
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