require 'rails_helper'
require 'validates_email_format_of/rspec_matcher'

describe Donation do

  it { should validate_presence_of(:email) }
  it { should validate_email_format_of(:email) }
  it { should validate_presence_of(:card_token) }
  it { should validate_presence_of(:employer) }
  it { should validate_presence_of(:occupation) }
  it { should validate_presence_of(:amount_in_cents) }
  it { should validate_numericality_of(:amount_in_cents) }

  describe "process" do
    it "creates subscription if recurring is true" do
      person = stub_person_find_or_initialize_by
      stub_payment_processor(customer_id: 'cus1', subscription_id: 'sub1')
      donation = build(:donation, recurring: true)

      donation.process

      expect_new_payment_processor_for(donation)
      expect(person).to have_received(:update).with(stripe_id: 'cus1')
      expect(person).to have_received(:create_subscription).
        with(remote_id: 'sub1')
    end

    it "charges card once if recurring is falsy" do
      processor = stub_payment_processor
      stub_person_find_or_initialize_by
      donation = build(:donation, recurring: false)

      donation.process

      expect_new_payment_processor_for(donation)
      expect(processor).to have_received(:charge)
    end

    it "updates CRM with donation info" do
      stub_payment_processor
      stub_person_find_or_initialize_by
      allow(NbDonationCreateJob).to receive(:perform_later)
      donation = build(:donation)

      donation.process

      expect(NbDonationCreateJob).to have_received(:perform_later).
        with(donation.amount_in_cents, { email: donation.email,
                                         occupation: donation.occupation,
                                         employer: donation.employer})
    end

    it "creates donate action on person" do
      stub_payment_processor
      person = stub_person_find_or_initialize_by
      donation = build(:donation)

      donation.process

      expect(person).to have_received(:create_action).
        with(hash_including(template_id: Activity::DEFAULT_TEMPLATE_IDS[:donate],
                            donation_amount_in_cents: donation.amount_in_cents))
    end
  end

  def expect_new_payment_processor_for(donation)
    expect(PaymentProcessor).to have_received(:new).
      with(amount_in_cents: donation.amount_in_cents,
           card: donation.card_token,
           email: donation.email,
           description: Donation::DEFAULT_DESCRIPTION % donation.email)
  end

  def stub_person_find_or_initialize_by
    person = spy('person')
    allow(Person).to receive(:find_or_initialize_by).and_return(person)
    person
  end

  def stub_payment_processor(customer_id: nil, subscription_id: nil)
    fake_customer = double('customer', id: customer_id,
                           subscription_id: subscription_id)
    processor = double('processor', charge: nil, create_customer: fake_customer)
    allow(PaymentProcessor).to receive(:new).and_return(processor)
    processor
  end
end
