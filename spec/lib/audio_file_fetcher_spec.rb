require 'rails_helper'

describe AudioFileFetcher do
  describe "#audio_url_for_key" do
    it "raises an error for invalid keys" do
      expect {
        AudioFileFetcher.audio_url_for_key('bad_key')
      }.to raise_error(ArgumentError)
    end
    it "returns an audio url for valid keys" do
      good_key = AudioFileFetcher::VALID_FILE_NAMES.sample
      response_url = AudioFileFetcher.audio_url_for_key(good_key)
      expected_url = ENV['TWILIO_AUDIO_AWS_BUCKET_URL'] + good_key + '.wav'
      expect(response_url).to eq(expected_url)
    end
  end

  describe "#encouraging_audio_for_count" do
    it "returns an encouraging_audio url" do
      target_count = Ivr::Call::MAXIMUM_CONNECTIONS-1
      expected_url = AudioFileFetcher.encouraging_audio_for_count(target_count)
      expect(expected_url).to match(/encouraging_#{target_count}/)
    end
    it "raise an error for invalid keys" do
      target_count = Ivr::Call::MAXIMUM_CONNECTIONS
      expect{
        AudioFileFetcher.encouraging_audio_for_count(target_count)
      }.to raise_error(ArgumentError)
    end
  end


end