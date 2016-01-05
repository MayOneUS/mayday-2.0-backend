require 'rails_helper'

describe V1::PaymentsController, type: :controller do

  describe "POST create" do
    it "displays error message if given bad paramenters" do
      donation = double('donation', process: false, errors: { foo: ['is bad'] })
      allow(Donation).to receive(:new).and_return(donation)

      post :create, bad_param: 'nonsense'

      expect(json(response)).to eq({ "errors" => {"foo"=>["is bad"]} })
    end
  end

  def json(response)
    JSON.parse(response.body)
  end
end
