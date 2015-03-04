class V1::EventsController < V1::BaseController

  def index
    @events = Event.where(starts_at: Time.now..4.weeks.from_now).order(:starts_at)
    render
  end

  def create_rsvp
    # Mario TODO: make following asyc
    response, status = rescue_error_messages do |variable|
      Integration::NationBuilder.create_person_and_rsvp(event_id: params[:event_id], person_attributes: params[:person], person_id: params[:person_id])
    end
    render json: response, status: status
  end

end
