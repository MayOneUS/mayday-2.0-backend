class V1::LegislatorsController < V1::BaseController

  def index
    render json: Legislator.with_includes
      .order(:first_name, :last_name)
      .to_json( methods: [:name, :title, :state_name, :eligible],
                only: [:id, :with_us])
  end

  def show
    legislator = Legislator.with_includes.find_by_bioguide_id(params[:id])
    render json: legislator
      .to_json( methods: [:name, :title, :state_name, :eligible, :image_url, :state_abbrev], only: [:with_us, :party])
  end

  def targeted
    render json: Legislator.with_includes.targeted
  end

  end

end
