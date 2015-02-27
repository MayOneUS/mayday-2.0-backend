class V1::LegislatorsController < V1::BaseController
  def index
    person = Person.find_or_initialize_by(email: params[:email])
    if person.save
      person.update_location(address: params[:address],
                           city:    params[:city],
                           state:   params[:state],
                           zip:     params[:zip])

      @target_legislators = person.target_legislators(json: true)
      @address_required   = person.address_required?
    else
      @error = "person not found"
    end
    render
  end
end
