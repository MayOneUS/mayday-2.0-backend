require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:start) { 1.day.from_now }
  let(:event_attributes) do
    {
      slug: "test_orientation_" + start.to_formatted_s(:number),
      name: "Mayday Call Campaign Orientation",
      start_time: start,
      end_time: start + 1.hour,
      status: "unlisted",
      autoresponse: {
        broadcaster_id: 1,
        subject: "Mayday orientation confirmation"
      }
    }
  end

  describe "#post_to_nation_builder" do
    context "creating new event without remote_id" do
      it "sends call to update NationBuilder" do
        expect(Integration::NationBuilder).to receive(:create_event)
          .with({ attributes: event_attributes })
        FactoryGirl.create(:event, starts_at: start, ends_at: start + 1.hour)
      end
    end

    context "creating new event with remote_id" do
      it "does nothing" do
        expect(Integration::NationBuilder).not_to receive(:create_event)
        FactoryGirl.create(:event, remote_id: 1)
      end
    end
  end

  describe "#remove_from_nation_builder" do
    it "sends call to destroy event on NationBuilder" do
      expect(Integration::NationBuilder).to receive(:destroy_event).with(1)
      FactoryGirl.create(:event, remote_id: 1).destroy
    end
  end
end
