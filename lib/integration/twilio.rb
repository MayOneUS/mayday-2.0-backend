class Integration::Twilio

  def place_call
    @call = self.class.client.calls.create(
      from: '+14159341234',
      to: '+18004567890',
      'ApplicationSid': ''
    )
    @call
  end

  private

  def self.client
    @client ||= Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
  end

end