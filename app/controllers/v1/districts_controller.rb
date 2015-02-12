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
      output = {}
      if zip_code = ZipCode.includes(:districts, :campaigns).find_by(zip_code: zip)
        output[:city]  = zip_code.city
        output[:state] = zip_code.state.abbrev
        output[:targeted] = if zip_code.targeted_by_campaign?(targeted_campaign)
          if zip_code.single_district?
            output[:district] = zip_code.single_district.district
            true
          else
            nil
          end
        else
          false
        end
      end
      output
    end

    def mcommons_district(coords)
      results = Integration::MobileCommons.district_from_coords(coords)

      district = District.includes(:campaigns, :state).where('states.abbrev': results[:state]).find_by(district: results[:district])
      targeted = district.present? && district.targeted_by_campaign?(targeted_campaign)

      results.merge({ targeted: targeted })
    end

    def here_coords(address, city, state, zip)
      Integration::Here.geocode_address( address: address,
                                         city:    city,
                                         state:   state,
                                         zip:     zip )
    end

    def targeted_campaign
      @targeted_campaign ||= Campaign.first
    end
end