class Integration::Stripe
  # generate tokens for testing
  # see https://stripe.com/docs/testing for test card numbers
  def self.generate_token(card_number: '4242424242424242')
    Stripe::Token.create(
      card: {
        number: card_number,
        exp_month: 12,
        exp_year: 2016,
        cvc: "314"
      },
    )
  end
end
