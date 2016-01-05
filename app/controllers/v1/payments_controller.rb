class V1::PaymentsController < V1::BaseController

  # Receives person, payment and action attributes. Creates/updates a person
  # creates an action, and creates a stripe single or recurring payment
  # Params:
  #  * email - string - person email
  #  * employer - string - person employer
  #  * occupation - string - person occupation
  #  * amount_in_cents - int - donation amount in cents
  #  * recurring - true - pass true if recurring donation
  #  * stripe_token - token returned by Stripe.js to identify credit card
  #  * template_id - action template_id
  #  * utm_source - action utm_source
  #  * utm_medium - action utm_medium
  #  * utm_campaign - action utm_campaign
  #  * source_url - action source_url
  def create
    payment_creator = Donation.new(payment_params)
    if payment_creator.process
      render json: { status: 'success' }
    else
      render json: { errors: payment_creator.errors }
    end
  end

  private

  def payment_params
    params.permit(:email, :employer, :occupation, :stripe_token, :recurring,
                  :utm_source, :utm_medium, :utm_campaign, :source_url,
                  :amount_in_cents)
  end
end
