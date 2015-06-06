class Ivr::CallsController < Ivr::ApplicationController

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

  # Public: initiates a new recording
  #
  # CallSid - default param from twilio (required)
  def new_recording
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
  # RecordingDuration - dialed call's remote_id from twilio (required)
  # RecordingUrl - dialed call's remote_id from twilio (required)
  def re_record_prompt
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

  private

  def close_call(twilio_renderer)
    twilio_renderer.Say('Please try again later.')
    play_audio(twilio_renderer, 'goodbye')
  end


end