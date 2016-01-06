require 'rails_helper'

RSpec.describe NbDonationCreateJob, type: :job do
  it "calls NationBuilder with correct args" do
    stub_nb_method(:create_or_update_person,
                   returning: { 'id' => 6 })
    stub_nb_method(:create_donation)

    NbDonationCreateJob.new.perform(300, { email: 'user@example.com' })

    expect(Integration::NationBuilder).to have_received(:create_donation).
      with(amount_in_cents: 300, person_id: 6)
  end

  def stub_nb_method(method, returning: nil)
    allow(Integration::NationBuilder).to receive(method).
      and_return(returning)
  end
end
