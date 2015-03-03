class V1::EventsController < V1::BaseController

  def index
    start = DateTime.parse("2015-03-14 6pm EST").utc
    events = []
    (1..7).each do |n|
      events << {
        "id":        n,
        "starts_at": start + n.days,
        "ends_at":   start + n.days + 2.hours,
      }
    end
    render json: { events: events }, status: 200
  end

  def create_rsvp
    # Mario TODO: make following asyc
    response, status = rescue_error_messages do |variable|
      Integration::NationBuilder.create_person_and_rsvp(event_id: params[:event_id], person_attributes: params[:person], person_id: params[:person_id])
    end
    render json: response, status: status
  end

end
