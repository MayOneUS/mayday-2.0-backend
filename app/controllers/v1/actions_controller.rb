class V1::ActionsController < V1::BaseController

  def create
    activity = Activity.find_by(template_id: params[:template_id])
    action = Action.create(person: person_from_params, activity: activity)
    if action.valid?
      output = { success: true }
    else
      output = { error: 'could not create action' }
    end
    render json: output
  end

  private

  def person_from_params
    Person.find_by(email: params[:email]) || Person.find_by(phone: params[:phone])
  end
end
