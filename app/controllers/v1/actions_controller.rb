class V1::ActionsController < V1::BaseController
  before_action :set_person, only: :create

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

  def count
    finder = Action
    finder = finder.by_type(params[:activity_type]) if params[:activity_type].present?
    if params[:start_at].present?
      start_at = DateTime.parse(params[:start_at])
      end_at = DateTime.parse(params[:end_at]) if params[:end_at].present?
      finder = finder.by_date(start_at, end_at)
    end
    render json: {count: finder.count}
  end

  private

  def activity_param
    params.require(:template_id)
  end

  def action_params
    params.permit(:utm_source, :utm_medium, :utm_campaign, :source_url,
                  :donation_amount_amount_in_cents, :strike_amount_in_cents,
                  :privacy_status)
  end

  def person_params
    params.require(:person).permit(Person::PERMITTED_PUBLIC_FIELDS)
  end

  def set_person
    person_params.map{|k,v| person_params[k] = v.try(:strip) || v }
    @person = Person.create_or_update(person_params) if person_params.present?
  end

end
