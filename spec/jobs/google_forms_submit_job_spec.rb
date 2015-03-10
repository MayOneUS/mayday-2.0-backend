require 'rails_helper'

RSpec.describe GoogleFormsSubmitJob, type: :job do
  describe "#perform" do
    it "passes args straight through to GoogleForms integration class" do
      expect(Integration::GoogleForms).to receive(:submit).
        with('form_id', { key: 'value' })
      GoogleFormsSubmitJob.new.perform('form_id', { key: 'value' })
    end
  end
end
