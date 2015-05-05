class V1::PeopleController < V1::BaseController

  def create
    @person = Person.create_or_update(person_params)
    if @person.valid?
      if template_ids = params[:actions].presence
        @person.mark_activities_completed(template_ids)
      end
    else
      @error = @person.error_message_output
    end
    render :show
  end

  def show
    logger.warn params[:identifier]
    @person = Person.includes(:actions)
      .where('email = :identifier OR uuid = :identifier OR phone = :identifier', identifier: params[:identifier])
      .first
    @error = "No person found for #{params[:identifier]}" if @person.nil?
    render
  end

  def delete_all
    # TODO remove in prod
    Person.destroy_all
    render text: "deleted all records"
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
    params.require(:person).permit(:email, :phone, :first_name, :last_name,
      :address, :zip, :is_volunteer, remote_fields: [:event_id, tags: []])
  end

  def location_params
    params.permit(:address, :zip)
  end
end
