require 'rails_helper'

describe Activity do
  it { should validate_uniqueness_of(:template_id) }

  describe "#donations_total_in_cents" do
    it "returns sum of strikes" do
      activity = create(:activity)
      create(:action, activity: activity, strike_amount_in_cents: 100)
      create(:action, activity: activity, strike_amount_in_cents: 300)

      total = activity.strike_total_in_cents

      expect(total).to eq 400
    end

    it "returns sum of donations" do
      activity = create(:activity)
      create(:action, activity: activity, donation_amount_in_cents: 100)
      create(:action, activity: activity, donation_amount_in_cents: 200)

      total = activity.donations_total_in_cents

      expect(total).to eq 300
    end
  end
end
