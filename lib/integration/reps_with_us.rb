class Integration::RepsWithUs

  DOMAIN           = 'apiv1.repswith.us'
  BILLS_PATH       = '/bills'
  BILLS_KEY        = 'bills'
  SPONSOR_KEY      = 'sponsor'
  COSPONSORS_KEY   = 'cosponsors'
  LEGISLATORS_PATH = '/legislators'
  LEGISLATOR_KEY   = 'legislator'
  SPONSORED_KEY    = 'sponsoredBills'
  COSPONSORED_KEY  = 'cosponsoredBills'

  def self.all_reps_with_us
    response = JSON.parse(RestClient.get(bills_url))
    reps = []
    if bills = response[BILLS_KEY]
      bills.each do |bill|
        sponsor    = bill[SPONSOR_KEY]
        cosponsors = bill[COSPONSORS_KEY]
        reps << sponsor if sponsor.is_a? String
        reps += cosponsors if cosponsors.is_a? Array
      end
    end
    reps.uniq
  rescue JSON::ParserError
    nil
  rescue RestClient::ResourceNotFound
    nil
  end

  def self.rep_with_us?(bioguide_id)
    response = JSON.parse(RestClient.get(legislator_url(bioguide_id)))
    if legislator = response[LEGISLATOR_KEY]
      legislator[SPONSORED_KEY].present? || legislator[COSPONSORED_KEY].present?
    end
  rescue JSON::ParserError
    nil
  rescue RestClient::ResourceNotFound
    nil
  end

  private

  def self.legislator_url(bioguide_id)
    base_url + LEGISLATORS_PATH + '/' + bioguide_id
  end

  def self.bills_url
    base_url + BILLS_PATH
  end

  def self.base_url
    'http://' + DOMAIN
  end
end