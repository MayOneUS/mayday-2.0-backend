require 'rails_helper'

describe V1::CallsController,  type: :controller do

  describe "#create" do
    before do
      @target_phone = '1-123-123-1234'
      @fake_sid = 'werl1l2312'
      call = FactoryGirl.build(:call, remote_id: @fake_sid)

      person = double('person')
      allow(person).to receive_message_chain(:calls, :create).and_return(call)
      allow(Person).to receive_message_chain(:create_with, :find_or_create_by).and_return(person)

      twilio_call = double('twilio_call')
      allow(twilio_call).to receive(:sid).and_return(@fake_sid)
      allow(Integration::Twilio).to receive(:initiate_congress_calling).and_return(twilio_call)
    end
    it "initates a twilio call" do
      post :create, phone: @target_phone
      expect(Integration::Twilio).to have_received(:initiate_congress_calling).with(phone: @target_phone)
    end
    it "returns the twilio call sid" do
      post :create, phone: @target_phone
      json_response = JSON.parse(response.body)
      expect(json_response['call_sid']).to eq(@fake_sid)
    end
  end
end