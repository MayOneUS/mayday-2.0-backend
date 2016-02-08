require 'rails_helper'

describe "GET /activities/:template_id/actions" do
  it "lists actions" do
    activity = create(:activity)
    create(:action, activity: activity, strike_amount_in_cents: 100)
    create(:action, activity: activity, strike_amount_in_cents: 300)
    create(:action, :hidden, activity: activity, strike_amount_in_cents: 700)

    get "/activities/#{activity.template_id}/actions", limit: 1, page: 2

    expect(json_body.values_at('count', 'current_page', 'limit')).to eq [3, 2, 1]
    expect(json_body['strike_total_in_cents']).to eq 1100
    expect(json_body['results'].count).to eq 1
  end
end
