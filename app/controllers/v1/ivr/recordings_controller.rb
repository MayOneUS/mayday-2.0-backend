class V1::Ivr::RecordingssController < V1::BaseController

  def create
    person = create_person_and_action(default_template_id: Activity::DEFAULT_TEMPLATE_IDS[:record])

    twilio_app_number = Integration::Twilio::APP_PHONE_NUMBERS[:record_message]
    twilio_call = Integration::Twilio.initiate_call(phone: person.phone, app_number: twilio_app_number)
    call = person.calls.create(remote_id: twilio_call.sid)

    render json: {call_sid: call.remote_id, targets: call.legislators_targeted}, status: 200
  end

end