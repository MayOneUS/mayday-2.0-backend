require 'rails_helper'

RSpec.describe NbPersonPushJob, type: :job do
  describe "#perform" do
    it "calls NationBuilder with correct args" do
      args = { attributes: { email: "user@example.com", phone: '510-555-9999' } }
      expect(Integration::NationBuilder).to receive(:create_or_update_person).with(args)
      NbPersonPushJob.new.perform("email"=>"user@example.com", "phone"=>"510-555-9999")
    end
  end
end
