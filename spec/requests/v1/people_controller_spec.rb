require 'rails_helper'

describe V1::PeopleController,  type: :controller do


  describe "POST create" do
    it "returns success" do
      post :create, {email: 'dude@gmail.com'}
      json_response = JSON.parse(response.body)

      expect(response).to be_success
      expect(json_response).to have_key('id')
      expect(json_response['id']).to eq(57126)
    end
  end

end