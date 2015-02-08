class Integration::Here

  GEOCODER_URL = 'http://geocoder.cit.api.here.com/6.2/geocode.json?gen=6'
  AUTH_PARAMS = 'app_id=%s&app_code=%s'

  def self.coords_from_text(address)
    url = [ GEOCODER_URL,
            AUTH_PARAMS % [ENV['HERE_ID'],
            ENV['HERE_CODE']], "searchtext=#{address}" ].join('&')
    response = JSON.parse(RestClient.get(url))
    address_name, coordinates = parse_response(response)

    { address_name: address_name,
      coordinates:  coordinates }
  end

  private

    def self.parse_response(response)
      address_name, coordinates = nil, nil
      if result = response['Response']['View'].first
        location = result['Result'].first['Location']
        coords = location['DisplayPosition']
        address_name = location['Address']['Label']
        coordinates  = [coords['Latitude'], coords['Longitude']]
      end
      [ address_name, coordinates ]
    end
end