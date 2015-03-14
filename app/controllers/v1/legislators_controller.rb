class V1::LegislatorsController < V1::BaseController

  def index
    render json: Legislator.includes({ district: :state }, :state)
      .order(:first_name, :last_name)
      .to_json( methods: [:name, :title, :state_name, :eligible],
                only: [:id, :with_us])
  end

  def targeted
    render json: Legislator.includes({ district: :state }, :state).targeted
  end

end
