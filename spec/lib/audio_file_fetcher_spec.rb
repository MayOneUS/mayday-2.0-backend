require 'rails_helper'

describe AudioFileFetcher do
  describe "#file_for_key" do
    it "raises an error for invalid keys" do
      expect {
        AudioFileFetcher.file_for_key('bad_key')
      }.to raise_error(ArgumentError)
    end
    it "returns an audio url for valid keys" do
      good_key = AudioFileFetcher::VALID_FILE_NAMES.sample
      response_url = AudioFileFetcher.file_for_key(good_key)
      expected_url = ENV['TWILIO_AUDIO_AWS_BUCKET_URL'] + good_key + '.wav'
      expect(response_url).to eq(expected_url)
    end
  end
end