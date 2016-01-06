class Donation
  include ActiveModel::Model

  attr_accessor :email, :employer, :occupation, :stripe_token, :recurring,
    :utm_source, :utm_medium, :utm_campaign, :source_url, :amount_in_cents

  validates :email, presence: true,
    email_format: { message: 'is not a valid email' }
  validates :employer, presence: true
  validates :occupation, presence: true
  validates :stripe_token, presence: true
  validates :amount_in_cents, presence: true,
    numericality: { greater_than: 0, only_integer: true }

  def process!
    if valid?
      process_payment
      record_donation
      create_donate_action
    else
      false
    end

  rescue Stripe::CardError => e
    errors.add(:stripe_token, e.json_body[:error][:message])
    false
  end

  private

  def process_payment
    if recurring
      stripe_customer = StripeCustomer.new(create_stripe_customer)
      person.update(stripe_id: stripe_customer.id)
      person.create_subscription(remote_id: stripe_customer.subscription_id)
    else
      create_stripe_charge
    end
  end

  def record_donation
    NbPersonPushJob.perform_later(email: email,
                                  employer: employer,
                                  occupation: occupation,
                                  donation_amount: amount_as_integer)
  end

  def create_donate_action
    person.create_action(utm_source: utm_source,
                         utm_medium: utm_medium,
                         utm_campaign: utm_campaign,
                         source_url: source_url,
                         template_id: 'donate',
                         donation_amount_in_cents: amount_as_integer)
  end

  def person
    @person ||= find_or_create_person
  end

  def find_or_create_person
    person = Person.find_or_initialize_by(email: email)
    person.update(skip_nb_update: true)
    person
  end

  def create_stripe_customer
    Stripe::Customer.create(source: stripe_token,
                            plan: 'one_dollar_monthly',
                            email: email,
                            quantity: amount_as_integer/100)
  end

  def create_stripe_charge
    Stripe::Charge.create(amount: amount_as_integer,
                          source: stripe_token,
                          currency: 'usd',
                          description: "donation from #{email}")
  end

  def amount_as_integer
    amount_in_cents.to_i
  end

  StripeCustomer = Struct.new(:stripe_customer) do
    def id
      stripe_customer.id
    end

    def subscription_id
      stripe_customer.subscriptions.data.first.id
    end
  end
end
