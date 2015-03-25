class V1::PeopleController < V1::BaseController

  def create
    person = Person.create_with(person_params).find_or_create_by(email: person_params[:email])
    if person.valid?
      output = { id: person.id }
    else
      output = { error: person.error_message_output }
    end
    render json: output , status: 200
  end

  def targets
    person = Person.find_or_initialize_by(email: params[:email])
    if person.save # valid? TODO: optimize location saving
      person.update_location(location_params.symbolize_keys)
      @target_legislators = person.target_legislators(json: true)
      @address_required   = person.address_required?
    else
      @error = person.error_message_output
    end
    render
  end

  private

  def person_params
    params.fetch(:person, {}).permit(:email, :phone, :first_name, :last_name,
      :address, :zip, remote_fields: [:event_id, :is_volunteer, tags: []])
  end

  def location_params
    params.permit(:address, :zip)
  end
end
