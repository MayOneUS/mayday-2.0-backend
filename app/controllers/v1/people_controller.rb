class V1::PeopleController < V1::BaseController

  def create
    person = Person.create_or_update(person_params)
    render json: { id: person.id }, status: 200
  end

  def targets
    person = Person.find_or_initialize_by(email: params[:email])
    if person.save
      person.update_location(location_params.symbolize_keys)
      @target_legislators = person.target_legislators(json: true)
      @address_required   = person.address_required?
    else
      @error = "person not found"
    end
    render
  end

  private

  def person_params
    params.require(:person).permit(:email, :phone, :first_name, :last_name,
      :address, :zip, remote_fields: [:event_id, :is_volunteer, tags: []])
  end

  def location_params
    params.permit(:address, :zip)
  end
end
