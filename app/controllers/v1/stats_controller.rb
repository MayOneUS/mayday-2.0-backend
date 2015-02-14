class V1::StatsController < V1::BaseController

  def index
    render json: ExternalCountFetcher.new.counts!, status: 200
  end

end
