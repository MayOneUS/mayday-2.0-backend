class Ivr::ApplicationController < Ivr::ApplicationController
  after_filter :set_header

  private

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
end