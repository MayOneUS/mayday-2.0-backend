class Integration::PledgeService

  PLEDGE_SERVICE_DOMAIN = 'pledge.mayday.us'
  ENDPOINTS = {
    donations_total: '/r/total',
    donations_count: '/r/num_pledges'
  }

  def self.donations_total
    request_handler(endpoint: ENDPOINTS[:donations_total], result_key: 'totalCents')
  end

  def self.donations_count
    request_handler(endpoint: ENDPOINTS[:donations_count], result_key: 'count')
  end

  private

  def self.request_handler(endpoint:, result_key:)
    result = JSON.parse(RestClient.get('https://'+PLEDGE_SERVICE_DOMAIN+endpoint, :verify_ssl => OpenSSL::SSL::VERIFY_NONE))
    result[result_key]
  end

end