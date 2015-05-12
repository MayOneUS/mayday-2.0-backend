class V1::CallsController < V1::BaseController

  def create
    person_params = params.require(:person).permit(:uuid, :email, :phone, :zip)
    action_params = params.permit(:template_id, :utm_source, :utm_medium, :utm_campaign, :source_url)

    person = Person.create_or_update(person_params)
    person.create_action(action_params)
    twilio_call = Integration::Twilio.initiate_call(phone: person.phone)
    call = person.calls.create(remote_id: twilio_call.sid)

    render json: {call_sid: call.remote_id, targets: call.legislators_targeted}, status: 200
  end

end
