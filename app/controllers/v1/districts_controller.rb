class V1::DistrictsController < V1::BaseController
  def index
    if address = params[:address].presence
      @results = get_coords(address, params[:city], params[:state], params[:zip])
      if coords = @results[:coordinates]
        if @district = District.includes(:target_rep, :target_senators).find_by_state_and_district(get_district(coords))
          @rep_targeted = @district.target_rep.present?
          @target_legislators = @district.target_legislators
        end
      end
    elsif zip = params[:zip].presence
      if @zip_code = ZipCode.includes(:target_reps, :target_senators).find_by(zip_code: params[:zip])
        @rep_targeted = @zip_code.target_reps.any?
        @target_legislators = @zip_code.target_legislators
        @district = @zip_code.try(:single_district)
      end
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
