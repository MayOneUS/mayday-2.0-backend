class V1::Ivr::CallsController < V1::BaseController

  def create
    call_type = (params[:call_type] || :call_congress).to_sym
    template_id = Activity::DEFAULT_TEMPLATE_IDS[call_type]
    twilio_app_number = Integration::Twilio::APP_PHONE_NUMBERS[call_type]

    person = create_person_and_action(default_template_id: template_id)
    twilio_call = Integration::Twilio.initiate_call(phone: person.phone, app_number: twilio_app_number)
    call = person.calls.create(remote_id: 'twilio_call.sid')

    output = {call_sid: call.remote_id}
    output.merge!(targets: call.legislators_targeted) if call_type == :call_congress

    render json: output, status: 200
  end

end