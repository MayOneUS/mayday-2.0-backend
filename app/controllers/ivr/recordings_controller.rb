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
    instructions_statment = 'In just a momement, we will play your recording back to you.  If you\'re satisfied with
        your recording, you can hang up at anytime.  Press any key if you wish to re record.'
    active_call.recordings.create!(duration: params['RecordingDuration'], recording_url: params['RecordingUrl'])
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Thank you.'
      r.Say instructions_statment
      r.Gather(
        action: ivr_recordings_new_recording_prompt_url,
        'numDigits' => 1,
        'finishOnKey' => ''
      ) do |gather|
        r.Play(active_recording.remote_url)
        r.Say instructions_statment
      end
      play_audio(r, 'goodbye')
      r.Hangup
    end

    render_twiml response
  end

  private

  def ready_for_connection?(twilio_renderer)
    twilio_renderer.Gather(action: ivr_recordings_new_recording_url, method: 'get', 'numDigits' => 1) do |gather|
      play_audio(twilio_renderer, 'press_star_to_continue')
      3.times do
        gather.Pause(length: 5)
        play_audio(twilio_renderer, 'press_star_to_continue')
      end
    end
  end

end