class Integration::Twilio

  def self.initiate_congress_calling(phone:)
    client.calls.create(
      'from' => ENV['TWILIO_APP_PHONE_NUMBER'],
      'to' => phone,
      'ApplicationSid' => ENV['TWILIO_APP_SID']
    )
  end

  private

  def self.client
    @@client ||= Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
  end

end