class Integration::Twilio

  APP_PHONE_NUMBERS = {
    call_congress: ENV['TWILIO_APP_PHONE_NUMBER'],
    record_message: ENV['TWILIO_APP_RECORDING_NUMBER']
  }

  def self.initiate_call(phone:, app_number: APP_PHONE_NUMBERS[:call_congress])
    client.calls.create(
      'from' => app_number,
      'to' => phone,
      'ApplicationSid' => ENV['TWILIO_APP_SID']
    )
  end

  private

  def self.client
    @@client ||= Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
  end

end