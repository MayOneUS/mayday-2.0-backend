class Integration::Sunlight

  DOMAIN = 'congress.api.sunlightfoundation.com'
  LEGISLATORS_ENDPOINT = '/legislators'
  RESULTS_KEY = 'results'
  RESULTS_COUNT_KEY = 'count'
  RELEVANT_KEYS = [
    'birthday',
    'chamber',
    # 'contact_form',
    # 'crp_id',
    'district',
    # 'facebook_id',
    # 'fax',
    # 'fec_ids',
    'first_name',
    'gender',
    # 'govtrack_id',
    # 'icpsr_id',
    'in_office',
    'last_name',
    # 'lis_id',
    'middle_name',
    'name_suffix',
    'nickname',
    # 'oc_email',
    # 'ocd_id',
    'office',
    'party',
    'phone',
    'senate_class',
    'state',
    'state_rank',
    'term_end',
    'term_start',
    # 'thomas_id',
    'title',
    # 'twitter_id',
    # 'votesmart_id',
    # 'website',
    # 'youtube_id',
    'bioguide_id'
  ]
  FIELD_NAMES = { 'district' => 'district_code', 'state' => 'state_abbrev' }

  def self.get_legislator(bioguide_id: nil, state: nil, district: nil, senate_class: nil)
    if params = legislator_params(bioguide_id, district, state, senate_class)
      response = get_json(rep_url(params))
      results_count = response[RESULTS_COUNT_KEY]
      results = response[RESULTS_KEY]
      output = { 'results_count' => results_count }
      if results_count == 1
        output['legislator'] = parse_legislator(results.first)
      end
      output
    else
      {}
    end
  end

  private

  def self.legislator_params(bioguide_id, district, state, senate_class)
    if bioguide_id
      { bioguide_id: bioguide_id }
    elsif district
      { state:    state,
        district: district }
    elsif state
      { state:        state,
        senate_class: senate_class }
    end
  end

  def self.parse_legislator(results)
    rename_fields(results.slice(*RELEVANT_KEYS))
  end

  def self.rename_fields(legislator_hash)
    FIELD_NAMES.each do |sunlight_name, new_name|
      legislator_hash[new_name] = legislator_hash.delete(sunlight_name)
    end
    legislator_hash
  end

  def self.get_json(endpoint_query)
    JSON.parse(RestClient.get(endpoint_query))
  end

  def self.rep_url(bioguide_id: nil, state: nil, district: nil, senate_class: nil)
    query_string = {
      apikey:       ENV['SUNLIGHT_KEY'],
      bioguide_id:  bioguide_id,
      state:        state,
      district:     district,
      senate_class: senate_class
    }.to_query

    ['http://', DOMAIN, LEGISLATORS_ENDPOINT, '?', query_string].join
  end

end