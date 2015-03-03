class V1::CallsController < V1::BaseController

  def create
    person = Person.create_with(phone: params[:phone]).find_or_create_by(email: params[:email])
    twilio_call = Integration::Twilio.initiate_congress_calling(phone: params[:phone])
    call = person.calls.create(remote_id: twilio_call.sid)
    render json: {call_sid: twilio_call.sid}, status: 200
  end

end
