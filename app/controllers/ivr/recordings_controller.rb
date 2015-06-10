class Ivr::RecordingsController < Ivr::ApplicationController

  after_filter :set_header

  # Public: initiates the call process via a request from twillio
  #
  # CallSid - default param from twilio (optional)
  def start
    find_or_create_active_call
    response = Twilio::TwiML::Response.new do |r|
      r.Pause
      ready_for_connection?(r)
      r.Say('Please try again later.')
      play_audio(r, 'goodbye')
    end

    render_twiml response
  end

  # Public: initiates a new recording
  #
  # CallSid - default param from twilio (required)
  def new_recording
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Your recording will begin at the beep.  Press 7 when you\'re finished recording'
      r.Record(action: ivr_recordings_re_record_prompt_url, method: 'post', 'finishOnKey' => '7')
    end

    render_twiml response
  end

  # Public: prompts a user reported response on how the connection preformed
  #
  # CallSid - active_call's remote_id from twilio(required)
  # RecordingDuration - dialed call's remote_id from twilio (required)
  # RecordingUrl - dialed call's remote_id from twilio (required)
  def re_record_prompt
    instructions_statment = 'In just a moment, we will play your recording back to you.  If you\'re satisfied with
        your recording, hang up.  If you wish to re re cord, press any button to go back.'
    active_recording = active_call.recordings.create!(duration: params['RecordingDuration'], recording_url: params['RecordingUrl'])
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Thank you.'
      r.Say instructions_statment
      r.Gather(
        action: ivr_recordings_new_recording_url,
        'numDigits' => 1,
        'finishOnKey' => ''
      ) do |gather|
        r.Play(active_recording.recording_url)
        r.Say instructions_statment
      end
      play_audio(r, 'goodbye')
      r.Hangup
    end

    render_twiml response
  end

  private

  def ready_for_connection?(twilio_renderer)
    instructions_statment = 'Press star when you\'re ready to start recording'
    twilio_renderer.Gather(action: ivr_recordings_new_recording_url, method: 'get', 'numDigits' => 1) do |gather|
      play_audio(r, 'recording_tool_intro')
      gather.Say instructions_statment
      3.times do
        gather.Pause(length: 5)
        gather.Say instructions_statment
      end
    end
  end

end