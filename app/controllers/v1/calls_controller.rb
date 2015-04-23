class V1::CallsController < V1::BaseController

  def create
    person = Person.create_or_update(params)
    twilio_call = Integration::Twilio.initiate_congress_calling(phone: params[:phone])
    call = person.calls.create(remote_id: twilio_call.sid)
    render json: {call_sid: call.remote_id}, status: 200
  end

end
