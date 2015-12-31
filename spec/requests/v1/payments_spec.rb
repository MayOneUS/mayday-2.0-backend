require "rails_helper"

RSpec.describe "POST /payments" do
  context "recurring payment, existing person" do
    it "creates subscription and action" do
      person = create(:person)
      customer = stub_stripe_customer_create(id: 'customer id',
                                             subscription_id: 'subscription id')

      post "/payments", amount: 400, source: 'test token', recurring: true,
        template_id: 'donate', person: { email: person.email }

      person.reload
      expect(person.stripe_id).to eq 'customer id'
      expect(person.subscription.remote_id).to eq 'subscription id'
      action = person.actions.last
      expect(action.donation_amount_in_cents).to eq 400
      expect(action.activity.template_id).to eq 'donate'
    end
  end

  context "simple payment, new person" do
    it "creates action" do
      allow(Stripe::Charge).to receive(:create)

      post "/payments", amount: 300, source: 'test token',
        template_id: 'donate', person: { email: 'test@example.com' }

      expect(Stripe::Charge).to have_received(:create).
        with(hash_including('amount' => '300', 'source' => 'test token',
                            currency: 'usd'))

      person = Person.find_by(email: 'test@example.com')
      action = person.actions.last
      expect(action.donation_amount_in_cents).to eq 300
      expect(action.activity.template_id).to eq 'donate'
    end
  end

  def stub_stripe_customer_create(id: '', subscription_id: '')
    fake_stripe_customer(id: id, subscription_id: subscription_id).tap do |cust|
      allow(Stripe::Customer).to receive(:create).and_return(cust)
    end
  end

  def fake_stripe_customer(id: '', subscription_id: '')
    subscription = Struct.new(:id).
      new(subscription_id)
    subscriptions = Struct.new(:data).
      new([subscription])
    Struct.new(:id, :subscriptions).
      new(id, subscriptions)
  end
end
