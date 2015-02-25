class V1::DistrictsController < V1::BaseController
  def index
    if email = params[:email].presence
      @user = Person.find_or_create_by(email: email)
      if address = params[:address].presence
        @user.district = District.find_by_address( address:  address,
                                                    city:    params[:city],
                                                    state:   params[:state],
                                                    zip:     params[:zip] )
      elsif zip = params[:zip].presence
        @user.zip_code = zip
        @user.district = ZipCode.find_by(zip_code: zip).try(:single_district)
      end
      @user.save
    end
    render
  end
end
