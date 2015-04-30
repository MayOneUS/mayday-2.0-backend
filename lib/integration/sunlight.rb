class Integration::Sunlight

  DOMAIN = 'congress.api.sunlightfoundation.com'
  ENDPOINTS = {
    bills:       '/bills',
    legislators: '/legislators'
  }
  RESULTS_KEY = 'results'
  RESULTS_COUNT_KEY = 'count'
  PAGE_KEY = 'page'
  PER_PAGE_KEY = 'per_page'
  MAX_PER_PAGE = 500 # it's actually 50, but a bigger number doesn't hurt
  DEFAULT_PARAMS = { apikey: ENV['SUNLIGHT_KEY'], per_page: MAX_PER_PAGE }
  JSON_PATHS = {
    bill: [
      'bill_id',
      # 'bill_type',
      'chamber',
      'congress',
      # 'cosponsor_ids',
      # 'cosponsors_count',
      'cosponsors.sponsored_on',
      'cosponsors.legislator.bioguide_id',
      'introduced_on',
      # 'last_action_at',
      # 'last_version_on',
      # 'last_vote_at',
      # 'number',
      'official_title',
      'short_title',
      'sponsor_id',
      # 'summary',
      'summary_short',
      'urls.opencongress'
    ],
    legislator: [
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
  }
  MAPPINGS = {
    bill: {
      'congress'          => 'congressional_session',
      'introduced_on'     => 'introduced_at',
      'urls.opencongress' => 'opencongress_url'
    },
    legislator: {
      'district' => 'district_code',
      'state'    => 'state_abbrev'
    }
  }
  ASSOCIATIONS = {
    bill: {
      'cosponsors' => {
        'sponsored_on' => 'cosponsored_at',
        'legislator.bioguide_id' => 'sponsor_id'
      }
    }
  }

  def self.get_legislators(params = {})
    get_all = params.delete(:get_all)
    url = endpoint_url(:legislators, params)

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
      output['legislators'] = parse_results(:legislator, results)
    end
    output
  end

  def self.get_bill(bill_id:)
    fields = JSON_PATHS[:bill].join(',')
    params = { bill_id: bill_id, fields: fields }
    url = endpoint_url(:bills, params)
    if response = get_json(url) 
      if response[RESULTS_COUNT_KEY] == 1
        results = response[RESULTS_KEY].first
        parse(:bill, results)
      end
    end
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

  def self.parse_results(type, results)
    parsed_results = []
    results.each do |obj|
      parsed_results << parse(type, obj)
    end
    parsed_results
  end

  def self.parse(type, hash)
    keys = top_level_keys(JSON_PATHS[type])
    pruned_hash = hash.slice(*keys)
    parsed_hash = rename_fields(pruned_hash, MAPPINGS[type])
    parse_associations(type, parsed_hash)
  end

  def self.parse_associations(type, hash)
    if association_hash = ASSOCIATIONS[type]
      association_hash.each do |key, mappings|
        hash[key] = hash[key].map { |obj| rename_fields(obj, mappings) }
      end
    end
    hash
  end

  def self.rename_fields(hash, mappings)
    mappings.each do |sunlight_path, local_name|
      hash[local_name] = get_object_at_path(hash, sunlight_path)
    end
    top_level_keys(mappings.keys).each { |key| hash.delete(key) }
    hash
  end

  def self.top_level_keys(paths)
    paths.map{ |p| p.split('.').first }.uniq
  end

  def self.get_object_at_path(hash, path)
    path.split('.').inject(hash) { |hash, key| hash.try(:[], key) }
  end

  def self.get_json(endpoint_query)
    JSON.parse(RestClient.get(endpoint_query))
  end

  def self.url_and_page(url, page)
    "#{url}&page=#{page}"
  end

  def self.endpoint_url(endpoint, params)
    query_string = DEFAULT_PARAMS.merge(params).to_query

    ['http://', DOMAIN, ENDPOINTS[endpoint], '?', query_string].join
  end

end