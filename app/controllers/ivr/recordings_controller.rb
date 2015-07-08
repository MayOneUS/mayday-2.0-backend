class Ivr::RecordingsController < Ivr::ApplicationController

  after_filter :set_header
  HOUSE_RECORDING_STRING = 'hr20'

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
      play_audio(r, 'recording_begin_at_beep')
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
    active_recording = active_call.recordings.create!(duration: params['RecordingDuration'], recording_url: params['RecordingUrl'])
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Thank you.'
      play_audio(r, 'recording_play_back')
      play_audio(r, 'recording_recrcord_instructions')
      r.Gather(
        action: ivr_recordings_new_recording_url,
        method: 'get',
        'numDigits' => 1,
        'finishOnKey' => ''
      ) do |gather|
        r.Play(active_recording.recording_url)
        play_audio(r, 'recording_play_back')
        play_audio(r, 'recording_recrcord_instructions')
      end
      play_audio(r, 'goodbye')
      r.Hangup
    end

    render_twiml response
  end

  private

  def ready_for_connection?(twilio_renderer)
    twilio_renderer.Gather(action: ivr_recordings_new_recording_url, method: 'get', 'numDigits' => 1) do |gather|
      if active_call.campaign_ref =~ /#{HOUSE_RECORDING_STRING}/i
        play_audio(gather, 'recording_tool_intro')
      else
        play_audio(gather, 'recording_tool_intro_senate')
      end
      play_audio(gather, 'recording_press_star_start')
      3.times do
        gather.Pause(length: 5)
        play_audio(gather, 'recording_press_star_start')
      end
    end
  end

end