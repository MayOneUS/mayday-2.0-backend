class V1::CongressionalDistrictController < V1::BaseController
  def index
    output = {}
    if address = params[:address].presence
      if results = coords_from_address(address)
        address_name = results[:address_name]
        coords = results[:coordinates]

        output = { address: address_name }.merge(district_from_coords(*coords))
      else
        output = { error: "couldn't find address" }
      end
    end

    render json: output
  end

  private
    def district_from_coords(lat, long)
      key = ENV['SUNLIGHT_KEY']
      url = "https://congress.api.sunlightfoundation.com/legislators/locate?latitude=#{lat}&longitude=#{long}&apikey=#{key}"
      response = open(url).read
      results = JSON.parse(response)['results']

      return { district: 'not found' } unless results.any?

      representative, senator_senior, senator_junior = [nil, nil, nil]
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
        legislators: { representative: representative,
                       senator_senior: senator_senior,
                       senator_junior: senator_junior } }
    
    rescue OpenURI::HTTPError => e
      byebug
    end

    def coords_from_address(address)
      key = ENV['BING_KEY']
      url = "http://dev.virtualearth.net/REST/v1/Locations?key=#{key}&q=#{address}"
      response = open(url).read
      result = JSON.parse(response)

      if resource = result['resourceSets'].first['resources'].first
        { address_name: resource['name'], 
          coordinates:  resource['point']['coordinates'], 
          confidence:   resource['confidence'], 
          address:      resource['address'],
          type:         resource['entityType'] }
      end
    
    rescue OpenURI::HTTPError => e
      byebug
    end
end