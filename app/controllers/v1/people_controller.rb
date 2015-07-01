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
    @person = Person.identify(params[:identifier]).first
    @error = "No person found for #{params[:identifier]}" if @person.nil?
    render
  end

  def targets
   @person = Person.create_or_update(person_params)
    if @person.valid?
      render
    else
      render json: {errors: @person.error_message_output}, status: :unprocessable_entity
    end
  end

  private

  def person_params
    params.require(:person).permit(Person::PERMITTED_PUBLIC_FIELDS)
  end

  def location_params
    params.require(:person).permit(:address, :zip)
  end
end
