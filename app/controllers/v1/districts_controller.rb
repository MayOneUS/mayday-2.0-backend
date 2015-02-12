class V1::DistrictsController < V1::BaseController
  def index
    if address = params[:address].presence
      output = get_coords(address, params[:city], params[:state], params[:zip])
      if coords = output[:coordinates]
        district_info  = get_district(coords)
        district = District.find_by_hash(district_info)
        output[:targeted] = district.try(:targeted?)
        output = output.merge(district_info)
      end

    elsif zip = params[:zip].presence
      output =  district_info_for_zip(zip)
    else
      output = { error: 'zip code is required' }
    end

    render json: output, status: 200
  end

  private

  def district_info_for_zip(zip)
    output = {}
    if zip_code = ZipCode.includes(:districts, :campaigns).find_by(zip_code: zip)
      if zip_code.targeted?
        if district = zip_code.single_district
          output[:district] = district.district
          output[:state]    = district.state.abbrev
          output[:targeted] = true
        else
          output[:state]    = zip_code.state.abbrev
          output[:city]     = zip_code.city
          output[:targeted] = nil
        end
      else
        output[:targeted] = false
      end
    end
    output
  end

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