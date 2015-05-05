class V1::ActionsController < V1::BaseController
  before_action :set_person

  def create
    activity = Activity.find_by(template_id: activity_param)

    action = Action.create(person: @person, activity: activity)
    if action.invalid?
      error_messages = action.errors.full_messages.join('. ') + '.'
      error_messages += ' Activity not found.' if activity.nil?
      @error = error_messages
    end
    render template: 'v1/people/show'
  end

  private

  def activity_param
    params.require(:template_id)#.permit(:utm_source, :utm_medium, :utm_campaign, :source_url)
  end

  def person_params
    params.require(:person).permit(:uuid, :email, :phone, :zip, :first_name, :last_name, :zip, :is_volunteer, :remote_fields)
  end

  def set_person
    person_params.map{|k,v| person_params[k]=v.strip}
    @person = Person.create_or_update(person_params) if person_params.present?
  end

end