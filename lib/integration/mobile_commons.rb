class Integration::MobileCommons

  DOMAIN = 'congress.mcommons.com'
  DISTRICT_LOOKUP_PATH = '/districts/lookup.json?lat=%s&lng=%s'
  CONGRESSIONAL_DISTRICT_KEY = 'federal'
  STATE_KEY = 'state'
  DISTRICT_KEY = 'district'
  SINGLE_DISTRICT_STATES = ["AK", "DE", "MT", "ND", "SD", "VI", "VT", "WY", "AS", "DC", "GU", "MP", "PR"]

  def self.district_from_coords(coords)
    response = JSON.parse(RestClient.get(district_lookup_url(coords)))
    if district_info = response[CONGRESSIONAL_DISTRICT_KEY]
      state = district_info['state']
      district = district_info['district'].to_i.to_s
      if SINGLE_DISTRICT_STATES.include?(state) && district == '1'
        district = '0'
      end
      { state:    state,
        district: district }
    else
      {}
    end
  end

  def self.district_lookup_url(coords)
    'http://' + DOMAIN + (DISTRICT_LOOKUP_PATH % coords)
  end
end