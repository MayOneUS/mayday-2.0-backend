class V1::LegislatorsController < V1::BaseController

  def targeted
    render json: Legislator.targeted.to_json
  end

end
