class V1::CallsController < V1::BaseController

  def create
    person = create_person_and_action(default_template_id: Activity::DEFAULT_TEMPLATE_IDS[:call])

    twilio_call = Integration::Twilio.initiate_call(phone: person.phone)
    call = person.calls.create(remote_id: twilio_call.sid)

    render json: {call_sid: call.remote_id, targets: call.legislators_targeted}, status: 200
  end

end
