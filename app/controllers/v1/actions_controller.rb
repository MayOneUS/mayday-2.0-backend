class V1::ActionsController < V1::BaseController
  before_action :set_person

  def create
    activity = Activity.find_or_create_by(template_id: activity_param)

    action_attributes = {person: @person, activity: activity}.merge(action_params)
    action = Action.create(action_attributes)
    if action.invalid?
      error_messages = action.errors.full_messages.join('. ') + '.'
      error_messages += ' Activity not found.' if activity.nil?
      @error = error_messages
    end
    render template: 'v1/people/show'
  end

  private

  def activity_param
    params.require(:template_id)
  end

  def action_params
    params.permit(:utm_source, :utm_medium, :utm_campaign, :source_url)
  end

  def person_params
    params.require(:person).permit(Person::PERMITTED_PUBLIC_FIELDS)
  end

  def set_person
    person_params.map{|k,v| person_params[k] = v.try(:strip) || v }
    @person = Person.create_or_update(person_params) if person_params.present?
  end

end