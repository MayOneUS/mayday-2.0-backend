class V1::ActionsController < V1::BaseController
  def create
    activity = Activity.find_by(template_id: params[:template_id])

    action = Action.create(person: person_from_params, activity: activity)
    if action.valid?
      output = { success: true }
    else
      output = { error: action.errors.full_messages.first }
    end
    render json: output
  end

  private

  def person_params
    params.require(:person).permit(:uuid, :email, :phone)
  end

  def person_from_params
    person = Person.create_or_update(person_params)
    person if person.valid?
  end

end
