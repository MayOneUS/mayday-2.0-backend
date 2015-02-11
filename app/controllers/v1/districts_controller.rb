class V1::DistrictsController < V1::BaseController
  def index
    if address = params[:address].presence
      results = here_coords(address, params[:city], params[:state], params[:zip])
      coords = results[:coordinates]
      district_info = coords ? mcommons_district(coords) : {}

      render json: { address:    results[:address_name],
                     confidence: results[:confidence],
                     coords: coords
                   }.merge(district_info)

    elsif zip = params[:zip].presence
      render json: district_info_for_zip(zip),
              status: 200
    else
      render json: { error: 'zip code is required' }
    end
  end

  private
    def district_info_for_zip(zip)
      targeted, district, city, state = nil
      if zip_code = ZipCode.find_by(zip_code: zip)
        city = zip_code.city
        state = zip_code.state.abbrev
        if zip_code.campaigns.include?(Campaign.first)
          if zip_code.districts.count == 1
            district = zip_code.districts.first
            state = district.state.abbrev
            district = district.district
            targeted = true
          end
        else
          targeted = false
        end
      end
      { targeted: targeted, district: district, city: city, state: state }
    end

    def mcommons_district(coords)
      results = Integration::MobileCommons.district_from_coords(coords)
      state = State.find_by(abbrev: results[:state])
      district = District.find_by(state: state, district: results[:district])
      targeted =  Campaign.first.districts.include?(district)
      results.merge({ targeted: targeted })
    end

    def here_coords(address, city, state, zip)
      Integration::Here.geocode_address( address: address,
                                         city:    city,
                                         state:   state,
                                         zip:     zip )
    end
end