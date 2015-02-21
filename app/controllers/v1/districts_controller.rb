class V1::DistrictsController < V1::BaseController
  def index
    @results = {}
    if address = params[:address].presence
      @results = get_coords(address, params[:city], params[:state], params[:zip])
      if coords = @results[:coordinates]
        @district = District.find_by_state_and_district(get_district(coords))
      end
    elsif zip = params[:zip].presence
      @zip_code = ZipCode.includes(:target_reps, :target_senators).find_by(zip_code: params[:zip])
      @district = @zip_code.try(:single_district)
    end
    render
  end

  private

  def get_district(coords)
    Integration::MobileCommons.district_from_coords(coords)
  end

  def get_coords(address, city, state, zip)
    Integration::Here.geocode_address( address: address,
                                       city:    city,
                                       state:   state,
                                       zip:     zip )
  end
end
