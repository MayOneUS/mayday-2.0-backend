class V1::DistrictsController < V1::BaseController
  def index
    @address_required = true
    local_targets = []
    if address = params[:address].presence
      if district = District.find_by_address( address:  address,
                                               city:     params[:city],
                                               state:    params[:state],
                                               zip:      params[:zip] )
        local_targets = district.target_legislators
        @district_id = district.id
        @address_required = false
      end
    elsif zip = params[:zip].presence
      if @zip_code = ZipCode.find_by(zip_code: params[:zip])
        local_targets = @zip_code.target_legislators
        if local_targets.any?
          @district_id = @zip_code.single_district.try(:id)
        end
        @address_required = @zip_code.address_required?
      end
    end
    ids = local_targets.map(&:id)
    default_targets = Legislator.default_targets(excluding: ids)
    @target_legislators = local_targets.as_json(local: true) + default_targets
    render
  end
end
