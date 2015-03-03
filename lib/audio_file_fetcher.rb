class AudioFileFetcher

  AWS_BUCKET = ENV['TWILIO_AUDIO_AWS_BUCKET_URL']

  VALID_FILE_NAMES = %w[
    closing_message
    connecting_local
    connecting_to_representative
    connecting_to_senator
    encouraging_1
    encouraging_2
    encouraging_3
    encouraging_4
    intro_message
    no_connection
    user_response
  ]

  def self.file_for_key(key)
    raise ArgumentError, 'Invalid audio file key' if !VALID_FILE_NAMES.include?(key)
    AWS_BUCKET + key + '.wav'
  end


end