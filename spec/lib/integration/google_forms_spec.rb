require 'rails_helper'

describe Integration::GoogleForms do
  describe ".submit" do
    it "builds url and posts form data" do
      expect(RestClient).to receive(:post).
        with('https://docs.google.com/forms/d/form_id/formResponse', { key: 'value' })

      Integration::GoogleForms.submit('form_id', { key: 'value' })
    end
  end
end