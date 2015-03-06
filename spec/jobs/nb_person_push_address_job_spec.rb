require 'rails_helper'

RSpec.describe NbPersonPushAddressJob, type: :job do
  describe "#perform" do
    it "calls NationBuilder with correct args" do
      args = { attributes: { email: "user@example.com", registered_address: { city: "Keene" } } }
      expect(Integration::NationBuilder).to receive(:create_or_update_person).with(args)
      NbPersonPushAddressJob.new.perform('user@example.com', city: 'Keene')
    end
  end
end
