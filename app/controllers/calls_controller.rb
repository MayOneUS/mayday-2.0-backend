class CallsController < ApplicationController

  after_filter :set_header

  # Public: initiates the call process via a request from twillio
  #
  # CallSid - default param from twilio (required)
  def start
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'We need you to connect with your congressperson and senator. We are going to put you in touch with '
      r.Say 'Whatever other intro text'
      r.Redirect calls_new_connection_url, method: 'get'
    end

    render_twiml response
  end

  # Public: initiates a new outgoing call to congress
  #
  # CallSid - default param from twilio (required)
  def new_connection
    response = Twilio::TwiML::Response.new do |r|
      if active_call.target_legislators.any?
        connection = active_call.create_connection!
        r.Say 'We will connect you in just a moment.  Press star at any time to disconnect from your legislator.'
        r.Dial connection.legislator.phone, 'action' => calls_connection_gather_prompt_url, 'hangupOnStar' => true
      else
        r.Say 'We don\'t have any targets for you. Please try again later.'
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
      r.Gather action: calls_connection_gather_url(connection_id: active_connection.id) do |gather|
        gather.Say 'How did the senator respond? Press 1 for positively, press 2 for negatively'
      end
    end

    render_twiml response
  end

  # Public: gathers the user response on connection preformance
  #
  # CallSid - active_call's remote_id from twilio (required)
  # Digits - the key pressed user response from twilio (required)
  # remote_id - remote_for the target connection (required)
  def connection_gather
    active_connection = Connection.find(params[:connection_id])
    active_connection.update(status_from_user: Connection::RESPONSE_CODES[params['Digits']])
    redirect_to calls_new_connection_path
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
    @call = Call.includes(connections: :legislator).where(remote_id: remote_id).first_or_create
  end

end