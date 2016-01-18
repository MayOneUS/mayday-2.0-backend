class Donation
  include ActiveModel::Model

  DEFAULT_DESCRIPTION = 'Donation from %s'

  attr_accessor :email, :employer, :occupation, :card_token, :recurring,
    :utm_source, :utm_medium, :utm_campaign, :source_url, :amount_in_cents

  attr_writer :template_id

  validates :email, presence: true, email_format: true
  validates :employer, presence: true
  validates :occupation, presence: true
  validates :card_token, presence: true
  validates :amount_in_cents, presence: true,
    numericality: { greater_than: 0, only_integer: true }

  def process
    if valid?
      find_or_create_person
      process_payment
      record_donation
      create_donate_action
    else
      false
    end

  rescue PaymentProcessor::CardError => e
    errors.add(:card_token, e.message)
    false
  end

  private

  attr_reader :person

  def find_or_create_person
    @person = Person.find_or_initialize_by(email: email)
    @person.update(skip_nb_update: true)
  end

  def process_payment
    if recurring
      customer = create_customer_and_subscription
      person.update(stripe_id: customer.id)
      person.create_subscription(remote_id: customer.subscription_id)
    else
      create_charge
    end
  end

  def record_donation
    NbDonationCreateJob.perform_later(amount_as_integer, person_attributes)
  end

  def create_donate_action
    person.create_action(donation_attributes)
  end

  def create_customer_and_subscription
    payment_processor.create_customer
  end

  def create_charge
    payment_processor.charge
  end

  def payment_processor
    PaymentProcessor.new(payment_processor_attributes)
  end

  def person_attributes
    {
      email: email,
      employer: employer,
      occupation: occupation
    }
  end

  def donation_attributes
    {
      utm_source: utm_source,
      utm_medium: utm_medium,
      utm_campaign: utm_campaign,
      source_url: source_url,
      template_id: template_id,
      donation_amount_in_cents: amount_as_integer
    }
  end

  def template_id
    @template_id ||= Activity::DEFAULT_TEMPLATE_IDS[:donate]
  end

  def payment_processor_attributes
    {
      card: card_token,
      amount_in_cents: amount_as_integer,
      email: email,
      description: DEFAULT_DESCRIPTION % email
    }
  end

  def amount_as_integer
    amount_in_cents.to_i
  end
end
