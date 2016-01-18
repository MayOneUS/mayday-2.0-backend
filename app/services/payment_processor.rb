class PaymentProcessor
  DEFAULT_DESCRIPTION = 'Payment from %s'
  PLAN_NAME = 'one_dollar_monthly'

  def initialize(card:, amount_in_cents:, email:, description: nil)
    @card = card
    @amount_in_cents = amount_in_cents
    @email = email
    @description = description || DEFAULT_DESCRIPTION % email
  end

  def charge
    rescue_stripe_errors do
      Stripe::Charge.create(charge_attributes)
    end
  end

  def create_customer
    rescue_stripe_errors do
      customer = Stripe::Customer.create(customer_attributes)
      StripeCustomer.new(customer)
    end
  end

  private

  attr_reader :card, :amount_in_cents, :email, :description

  def rescue_stripe_errors
    yield
  rescue Stripe::CardError => e
    raise CardError.new(e.message)
  end

  def charge_attributes
    {
      amount: amount_in_cents,
      source: card,
      currency: 'usd',
      description: description
    }
  end

  def customer_attributes
    {
      email: email,
      source: card,
      plan: PLAN_NAME,
      quantity: amount_in_dollars
    }
  end

  def amount_in_dollars
    amount_in_cents/100
  end

  class StripeCustomer
    attr_reader :id, :subscription_id

    def initialize(stripe_customer)
      @id = stripe_customer.id
      @subscription_id = stripe_customer.subscriptions.first.id
    end
  end

  class CardError < StandardError
  end
end
