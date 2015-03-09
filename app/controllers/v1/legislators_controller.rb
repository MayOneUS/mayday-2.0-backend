class V1::LegislatorsController < V1::BaseController

  def index
    render
  end

  def targeted
    render json: Legislator.includes({ district: :state }, :state).targeted
  end

end
