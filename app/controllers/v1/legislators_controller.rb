class V1::LegislatorsController < V1::BaseController
  def index
    user = Person.find_or_initialize_by(email: params[:email])
    if user.save
      user.update_location( address: params[:address],
                            city:    params[:city],
                            state:   params[:state],
                            zip:     params[:zip] )

      @target_legislators = user.target_legislators(json: true)
      @address_required   = user.address_required?
    else
      @error = "user not found"
    end
    render
  end
end
