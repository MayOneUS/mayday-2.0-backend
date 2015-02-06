require 'rails_helper'

describe Integration::PledgeService do

  def pledge_service_url(endpoint)
    'https://'+Integration::PledgeService::PLEDGE_SERVICE_DOMAIN+endpoint
  end

  describe "#donations_total" do
    it "formats url for target endpoint" do
      expect(Integration::PledgeService)
      .to receive(:request_handler)
      .with(endpoint: Integration::PledgeService::ENDPOINTS[:donations_total], result_key: 'totalCents')
      .and_call_original
    Integration::PledgeService.donations_total
    end
    it "responsed with a parsed total cents donated" do
      response = Integration::PledgeService.donations_total
      expect(response).to eq 748608206
    end
  end

  describe "#donations_count" do
    it "formats url for target endpoint" do
      expect(Integration::PledgeService)
      .to receive(:request_handler)
      .with(endpoint: Integration::PledgeService::ENDPOINTS[:donations_count], result_key: 'count')
      .and_call_original
    Integration::PledgeService.donations_count
    end
    it "responsed with a parsed total cents donated" do
      response = Integration::PledgeService.donations_count
      expect(response).to eq 65136
    end
  end

end