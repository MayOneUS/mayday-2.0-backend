class V1::CongressionalDistrictController < V1::BaseController
  def index
    output = {}
    if address = params[:address].presence

      if bing_results = bing_coords(address)
        coords = bing_results[:coordinates]
        here_results = here_coords(address)
        google_results = google_coords(address)
        output = { bing_address:   bing_results[:address_name],
                   bing_time:      bing_results[:time],
                   bing_coords:    coords,
                   google_address: google_results[:address_name],
                   google_time:    google_results[:time],
                   here_address:   here_results[:address_name],
                   here_time:      here_results[:time],
                   here_coords:    here_results[:coordinates],
                   sunlight:       sunlight_district(*coords),
                   mcommons:       mcommons_district(*coords) }
      else
        output = { error: "couldn't find address" }
      end
    end

    render json: output
  end

  def test_here
    addresses = ['727 N 1550 E Ste 410 Orem Ut',
                 '1402 West Center St Orem Ut',
                 '1224 south 760 west provo ut',
                 '1103 W 1130 N Orem Ut',
                 '765 Academy Dr Bessemer AL',
                 '2665 S Alma School Rd Mesa AZ',
                 '105 W Main St Brawley CA',
                 '1994 Silas Deane Hwy Rocky Hill CT',
                 '9900 Fm 1079 Cross Plains TX',
                 '15270 Coyote Falls Rd Entiat WA]']
    addresses *= 50
    results = []
    time = Benchmark.realtime { results = lookup_addresses(addresses) }
    render json: { results: results,
                   address_count: addresses.length,
                   time: time }
  end

  private
    def lookup_addresses(addresses)
      results = []
      addresses.each do |address|
        results << here_coords(address)
      end
      results
    end

    def sunlight_district(lat, long)
      key = ENV['SUNLIGHT_KEY']
      url = "https://congress.api.sunlightfoundation.com/legislators/locate?latitude=#{lat}&longitude=#{long}&apikey=#{key}"
      response = nil
      time = Benchmark.realtime { response = open(url).read }
      results = JSON.parse(response)['results']

      return { district: 'not found' } unless results.any?

      representative, senator_senior, senator_junior = nil, nil, nil
      results.each do |person|
        if person['chamber'] == 'house'
          representative = person 
        elsif person['chamber'] == 'senate'
          if person['state_rank'] == 'senior'
            senator_senior = person
          elsif person['state_rank'] == 'junior'
            senator_junior = person
          end
        end
      end

      { district: representative['district'],
        time: time,
        legislators: { representative: representative,
                       senator_senior: senator_senior,
                       senator_junior: senator_junior } }
    
    rescue OpenURI::HTTPError => e
      byebug
    end

    def mcommons_district(lat, long)
      url = "http://congress.mcommons.com/districts/lookup.json?lat=#{lat}&lng=#{long}"
      response = nil
      time = Benchmark.realtime { response = open(url).read }
      results = JSON.parse(response)['federal']
      results.merge({ time: time })
    end

    def bing_coords(address)
      key = ENV['BING_KEY']
      url = "http://dev.virtualearth.net/REST/v1/Locations?key=#{key}&q=#{address}"
      response = nil
      time = Benchmark.realtime { response = open(url).read }
      result = JSON.parse(response)

      if resource = result['resourceSets'].first['resources'].first
        { address_name: resource['name'], 
          coordinates:  resource['point']['coordinates'], 
          confidence:   resource['confidence'], 
          address:      resource['address'],
          type:         resource['entityType'],
          time:         time }
      end
    
    rescue OpenURI::HTTPError => e
      byebug
    end

    def here_coords(address)
      app_id = ENV['HERE_ID']
      app_code = ENV['HERE_CODE']
      url = "http://geocoder.cit.api.here.com/6.2/geocode.json?searchtext=#{address}&app_id=#{app_id}&app_code=#{app_code}&gen=6"
      response = nil
      time = Benchmark.realtime { response = open(url).read }
      address_name, coordinates = nil, nil
      if result = JSON.parse(response)['Response']['View'].first
        location = result['Result'].first['Location']
        coords = location['DisplayPosition']
        address_name = location['Address']['Label']
        coordinates  = [coords['Latitude'], coords['Longitude']]
      end
      { address_name: address_name,
        coordinates:  coordinates,
        time:         time }
    rescue OpenURI::HTTPError => e
      byebug
    end

    def google_coords(address)
      url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{address}"
      response = nil
      time = Benchmark.realtime { response = open(url).read }
      address_name, coordinates = nil, nil
      if result = JSON.parse(response)['results'].first
        coords = result['geometry']['location']
        address_name = result['formatted_address']
        coordinates  = [coords['lat'], coords['lng']]
      end
      { address_name: address_name,
        coordinates:  coordinates,
        time:         time }
    rescue OpenURI::HTTPError => e
      byebug
    end
end