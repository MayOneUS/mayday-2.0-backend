class Integration::Sunlight

  DOMAIN = 'congress.api.sunlightfoundation.com'
  LEGISLATORS_ENDPOINT = '/legislators'
  RESULTS_KEY = 'results'
  RESULTS_COUNT_KEY = 'count'
  PAGE_KEY = 'page'
  PER_PAGE_KEY = 'per_page'
  MAX_PER_PAGE = 500 # it's actually 50, but a bigger number doesn't hurt
  RELEVANT_KEYS = [
    'birthday',
    'chamber',
    # 'contact_form',
    # 'crp_id',
    'district',
    'facebook_id',
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
    'twitter_id',
    # 'votesmart_id',
    # 'website',
    # 'youtube_id',
    'bioguide_id'
  ]
  FIELD_NAMES = { 'district' => 'district_code', 'state' => 'state_abbrev' }

  def self.get_legislators( bioguide_id:  nil,
                           state:        nil,
                           district:     nil,
                           senate_class: nil,
                           get_all:      nil )

    url = legislators_url( bioguide_id:  bioguide_id,
                           state:        state,
                           district:     district,
                           senate_class: senate_class )

    output = {}
    if response = get_results_page(url_and_page(url, 1))
      results_count = response['results_count']
      results       = response['results']
      page_count    = response['page_count']

      output ['results_count'] = results_count

      if get_all
        (2..page_count).each do |n|
          response = get_results_page(url_and_page(url, n))
          results += response['results']
        end
      end
      output['legislators'] = parse_legislators(results)
    end
    output
  end

  private

  def self.get_results_page(url)
    response = get_json(url)
    results_count = response[RESULTS_COUNT_KEY]
    results = response[RESULTS_KEY]
    page_info = response[PAGE_KEY]

    if page_info
      page_count = (results_count.to_f / page_info[PER_PAGE_KEY]).ceil
      { 'results_count' => results_count,
        'results'       => results,
        'page_count'    => page_count }
    else
      nil
    end
  end

  def self.parse_legislators(results)
    legislators = []
    results.each do |legislator|
      legislators << parse_legislator(legislator)
    end
    legislators
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

  def self.url_and_page(url, page)
    "#{url}&page=#{page}"
  end

  def self.legislators_url(bioguide_id: nil, state: nil, district: nil,
                                            senate_class: nil)
    query_string = {
      apikey:       ENV['SUNLIGHT_KEY'],
      bioguide_id:  bioguide_id,
      state:        state,
      district:     district,
      senate_class: senate_class,
      per_page:     MAX_PER_PAGE
    }.to_query

    ['http://', DOMAIN, LEGISLATORS_ENDPOINT, '?', query_string].join
  end

end