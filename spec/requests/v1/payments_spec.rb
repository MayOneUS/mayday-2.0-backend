require "rails_helper"

RSpec.describe "POST /payments" do
  context "recurring payment, existing person" do
    it "creates subscription and action and updates CRM" do
      person = create(:person)
      customer = stub_stripe_customer_create(id: 'customer id',
                                             subscription_id: 'subscription id')
      allow(NbPersonPushJob).to receive(:perform_later)

      post "/payments", amount_in_cents: 400, stripe_token: 'test token',
        recurring: true, email: person.email, occupation: 'job',
        employer: 'work place'

      expect(Stripe::Customer).to have_received(:create).
        with(source: 'test token',
             plan: 'one_dollar_monthly',
             email: person.email,
             quantity: 4)
      expect(NbPersonPushJob).to have_received(:perform_later).
        with(email: person.email, occupation: 'job', employer: 'work place', donation_amount: 400)
      person.reload
      expect(person.stripe_id).to eq 'customer id'
      expect(person.subscription.remote_id).to eq 'subscription id'
      action = person.actions.last
      expect(action.donation_amount_in_cents).to eq 400
      expect(action.activity.template_id).to eq 'donate'
    end
  end

  context "simple payment, new person" do
    it "creates person and action and updates CRM" do
      allow(Stripe::Charge).to receive(:create)
      allow(NbPersonPushJob).to receive(:perform_later)

      post "/payments", amount_in_cents: 300, stripe_token: 'test token',
        email: 'test@example.com', occupation: 'job', employer: 'work place'

      expect(Stripe::Charge).to have_received(:create).
        with(hash_including(amount: 300, source: 'test token',
                            currency: 'usd'))
      expect(NbPersonPushJob).to have_received(:perform_later).
        with(email: 'test@example.com', occupation: 'job', employer: 'work place', donation_amount: 300)
      person = Person.find_by(email: 'test@example.com')
      action = person.actions.last
      expect(action.donation_amount_in_cents).to eq 300
      expect(action.activity.template_id).to eq 'donate'
    end
  end

  def stub_stripe_customer_create(id: '', subscription_id: '')
    subscriptions = OpenStruct.new(data: [OpenStruct.new(id: subscription_id)])
    customer = double('customer', id: id, subscriptions: subscriptions)
    allow(Stripe::Customer).to receive(:create).and_return(customer)
  end
end
