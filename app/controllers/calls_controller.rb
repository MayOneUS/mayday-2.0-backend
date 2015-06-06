class CallsController < ApplicationController

  after_filter :set_header

  # Public: initiates the call process via a request from twillio
  #
  # CallSid - default param from twilio (optional)
  def start
    response = Twilio::TwiML::Response.new do |r|
      r.Pause
      play_audio(r, 'intro_message')
      ready_for_connection?(r)
      close_call(r)
    end

    render_twiml response
  end

  # Public: initiates a new outgoing call to congress. If ENV FAKE_CONGRESS_NUMBER is
  # set, then the all calls will be routed to that number.
  #
  # CallSid - default param from twilio (required)
  def new_connection
    response = Twilio::TwiML::Response.new do |r|
      if active_call.next_target.present?
        connection = active_call.create_connection!
        play_audio(r, connection.connecting_message_key)
        play_audio(r, 'star_to_disconnect')
        target_number = ENV['FAKE_CONGRESS_NUMBER'] || connection.legislator.phone
        r.Dial target_number, 'action' => calls_connection_gather_prompt_url, 'hangupOnStar' => true, 'callerId' => caller_id
      else
        close_call(r)
      end
    end

    render_twiml response
  end

  # Public: prompts a user reported response on how the connection preformed
  #
  # CallSid - active_call's remote_id from twilio(required)
  # DialCallSid - dialed call's remote_id from twilio (required)
  def connection_gather_prompt
    active_connection = active_call.last_connection
    active_connection.update!(remote_id: params['DialCallSid'], status: params['DialCallStatus'])
    response = Twilio::TwiML::Response.new do |r|
      r.Pause(length:2) #prevents user from accidentaly pushing * for this gather prompt
      r.Gather(
        action: calls_connection_gather_url(connection_id: active_connection.id),
        'numDigits' => 1,
        'finishOnKey' => ''
      ) do |gather|
        play_audio(r, 'user_response')
        gather.Pause(length:5)
        play_audio(r, 'user_response')
      end
      r.Redirect calls_new_connection_url, method: 'get'
    end

    render_twiml response
  end

  # Public: gathers the user response on connection preformance
  #
  # CallSid - active_call's remote_id from twilio (required)
  # Digits - the key pressed user response from twilio (required)
  # connection_id - remote_for the target connection (required)
  def connection_gather
    active_connection = Ivr::Connection.find(params[:connection_id])
    active_connection.update(status_from_user: Ivr::Connection::USER_RESPONSE_CODES[params['Digits']])
    response = Twilio::TwiML::Response.new do |r|
      if active_call.finished_loop?
        close_call(r)
      else
        r.Play AudioFileFetcher.encouraging_audio_for_count(active_call.encouraging_count)
        ready_for_connection?(r)
        close_call(r)
      end
    end

    render_twiml response
  end

  private

  def ready_for_connection?(twilio_renderer)
    twilio_renderer.Gather(action: calls_new_connection_url, method: 'get', 'numDigits' => 1) do |gather|
      play_audio(twilio_renderer, 'press_star_to_continue')
      3.times do
        gather.Pause(length: 5)
        play_audio(twilio_renderer, 'press_star_to_continue')
      end
    end
  end

  def close_call(twilio_renderer)
    if active_call.finished_loop? || active_call.next_target.nil?
      if active_call.next_target.present?
        twilio_renderer.Gather(action: calls_new_connection_url, method: 'get') do |gather|
          play_audio(twilio_renderer, 'closing_message')
          3.times do
            play_audio(twilio_renderer, 'there_are_more')
            gather.Pause(length: 7)
          end
        end
      else
        play_audio(twilio_renderer, 'no_targets')
      end
    end
    play_audio(twilio_renderer, 'goodbye')
    twilio_renderer.Hangup
  end

  def play_audio(twilio_renderer, audio_key)
    twilio_renderer.Play AudioFileFetcher.audio_url_for_key(audio_key)
  end

  def set_header
    response.headers["Content-Type"] = "text/xml"
  end

  def render_twiml(response)
    render text: response.text
  end

  def active_call
    @call ||= find_or_create_active_call
  end

  def find_or_create_active_call
    remote_id = params['CallSid'] || params[:remote_id]
    call = Ivr::Call.includes(:person).find_or_initialize_by(remote_id: remote_id)
    if call.new_record?
      call.person = Person.find_or_initialize_by(phone: params[:From])
      call.save!
    end
    call
  end

  def caller_id
    @caller_id ||= set_caller_id
  end

  def set_caller_id
    if params['To'] && params['Caller'] !~ /client/
      params['To']
    else
      Integration::Twilio::APP_PHONE_NUMBERS[:call_congress]
    end
  end

end