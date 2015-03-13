require 'rails_helper'

RSpec.describe NbPersonPushJob, type: :job do
  describe "#perform" do
    it "calls NationBuilder with correct args" do
      args = { attributes: { email: 'user@example.com', phone: '510-555-9999' } }
      expect(Integration::NationBuilder).to receive(:create_or_update_person).with(args)
      NbPersonPushJob.new.perform(email: 'user@example.com', phone: '510-555-9999')
    end

    it "creates RSVP when event_id is present" do
      args = { attributes: { email: 'user@example.com' } }
      expect(Integration::NationBuilder).to receive(:create_or_update_person)
        .with(args) { { 'id' => 6 } }
      expect(Integration::NationBuilder).to receive(:create_rsvp)
        .with(event_id: 4, person_id: 6)
      NbPersonPushJob.new.perform(email: 'user@example.com', event_id: 4)
    end
  end
end
