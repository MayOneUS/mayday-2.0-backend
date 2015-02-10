class V1::EventsController < V1::BaseController

  def create_rsvp
    # Mario TODO: make following asyc
    Integration::NationBuilder.create_person_and_rsvp(event_id: params[:event_id], person_attributes: params[:person])
    render json: {}, status: 200
  end

end
