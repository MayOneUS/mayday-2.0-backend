require 'rails_helper'

describe PaymentProcessor do
  describe "#charge" do
    it "charges card" do
      allow(Stripe::Charge).to receive(:create)
      processor = PaymentProcessor.new(card: 'tok1',
                                       amount_in_cents: 400,
                                       email: 'test@example.com',
                                       description: 'charge')

      processor.charge

      expect(Stripe::Charge).to have_received(:create).
        with(amount: 400, source: 'tok1', currency: 'usd', description: 'charge')
    end
  end

  describe "#create_customer" do
    it "creates subscription and returns Stripe customer" do
      stub_stripe_customer_create(id: 'cus1', subscription_id: 'sub1')
      processor = PaymentProcessor.new(card: 'tok1',
                                       amount_in_cents: 400,
                                       email: 'test@example.com',
                                       description: 'charge')

      customer = processor.create_customer

      expect(Stripe::Customer).to have_received(:create).
        with(email: 'test@example.com',
             source: 'tok1',
             plan: PaymentProcessor::PLAN_NAME,
             quantity: 4)
      expect(customer.id).to eq 'cus1'
      expect(customer.subscription_id).to eq 'sub1'
    end
  end

  def stub_stripe_customer_create(id: '', subscription_id: '')
    subscriptions = [OpenStruct.new(id: subscription_id)]
    customer = double('customer', id: id, subscriptions: subscriptions)
    allow(Stripe::Customer).to receive(:create).and_return(customer)
  end
end
