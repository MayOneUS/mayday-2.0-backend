class Integration::MobileCommons

  DISTRICT_URL = 'http://congress.mcommons.com/districts/lookup.json?lat=%s&lng=%s'

  def self.district_from_coords(coords)
    response = JSON.parse(RestClient.get(DISTRICT_URL % coords))
    if district = response['federal'] 
      state = State.find_by(abbrev: district['state'])
      district = District.find_by(state: state, district: district['district'].to_i.to_s)
    end
  end

end