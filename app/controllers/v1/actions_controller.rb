class V1::ActionsController < V1::BaseController
  before_action :set_person

  def create
    activity = Activity.find_by(template_id: params[:template_id])

    action = Action.create(person: @person, activity: activity)
    if action.invalid?
      @error = action.errors.full_messages.join('. ') + '.'
    end
    render
  end

  private

  def person_params
    params.require(:person).permit(:uuid, :email, :phone, :zip)
  end

  def set_person
    @person = Person.create_or_update(person_params) if person_params.present?
  end

end
2