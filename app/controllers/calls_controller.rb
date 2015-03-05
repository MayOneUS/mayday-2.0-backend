class CallsController < ApplicationController

  after_filter :set_header

  # Public: initiates the call process via a request from twillio
  #
  # CallSid - default param from twilio (required)
  def start
    response = Twilio::TwiML::Response.new do |r|
      r.Play AudioFileFetcher.audio_url_for_key('intro_message')
      r.Redirect calls_new_connection_url, method: 'get'
    end

    render_twiml response
  end

  # Public: initiates a new outgoing call to congress. If ENV FAKE_CONGRESS_NUMBER is
  # set, then the all calls will be routed to that number.
  #
  # CallSid - default param from twilio (required)
  def new_connection
    response = Twilio::TwiML::Response.new do |r|
      if active_call.next_target.present? && !active_call.exceeded_max_connections?
        connection = active_call.create_connection!
        # r.Play AudioFileFetcher.audio_url_for_key('connecting_local')
        r.Play AudioFileFetcher.audio_url_for_key('connecting_to_representative')
        r.Play AudioFileFetcher.audio_url_for_key('star_to_disconnect')
        target_number = ENV['FAKE_CONGRESS_NUMBER'] || connection.legislator.phone
        r.Dial target_number, 'action' => calls_connection_gather_prompt_url, 'hangupOnStar' => true
      else
        audio_key = active_call.exceeded_max_connections? ? 'closing_message' : 'no_targets'
        r.Play AudioFileFetcher.audio_url_for_key(audio_key)
        r.Play AudioFileFetcher.audio_url_for_key('goodbye')
        r.Hangup
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
    active_connection.update(remote_id: params['DialCallSid'])
    response = Twilio::TwiML::Response.new do |r|
      r.Gather(
        action: calls_connection_gather_url(connection_id: active_connection.id),
      ) do |gather|
        r.Play AudioFileFetcher.audio_url_for_key('user_response')
        gather.Pause
        r.Play AudioFileFetcher.audio_url_for_key('user_response')
      end
      r.Redirect calls_new_connection_url, method: 'get'
    end

    render_twiml response
  end

  # Public: gathers the user response on connection preformance
  #
  # CallSid - active_call's remote_id from twilio (required)
  # Digits - the key pressed user response from twilio (required)
  # remote_id - remote_for the target connection (required)
  def connection_gather
    active_connection = Ivr::Connection.find(params[:connection_id])
    active_connection.update(status_from_user: Ivr::Connection::USER_RESPONSE_CODES[params['Digits']])
    response = Twilio::TwiML::Response.new do |r|
      connection_count = active_call.connections.size
      r.Play AudioFileFetcher.encouraging_audio_for_count(connection_count)
      r.Redirect calls_new_connection_url, method: 'get'
    end

    render_twiml response
  end

  private

  def set_header
    response.headers["Content-Type"] = "text/xml"
  end

  def render_twiml(response)
    render text: response.text
  end

  def active_call
    remote_id = params['CallSid'] || params[:remote_id]
    @call = Ivr::Call.includes(connections: :legislator).where(remote_id: remote_id).first_or_create
  end

end