require 'rails_helper'

describe CallsController,  type: :controller do


  describe "GET start" do
    it "redirects to new_connection" do
      get :start, 'CallSid': 123
      xml_response = JSON.parse(response.body)
      pending
      expect(response).to be_success
      expect(xml_response).to have_key('redirect')
      expect(xml_response['id']).to eq(new_connection_path)
    end
  end

  describe "GET new_connection" do
    context "with a target" do
      it "dials the right number" do
        get :new_connection, 'CallSid': 123
        pending
      end
      it "creates a new connection" do
        get :new_connection, 'CallSid': 123
        pending
      end
    end
    context "with no target" do
      it "says sorry" do
        get :new_connection, 'CallSid': 123
        pending
      end
      it "hangs up" do
        get :new_connection, 'CallSid': 123
        pending
      end
    end
  end

  describe "POST connection_gather_prompt" do
    it "finds the correct active_connection" do
      post :connection_gather_prompt, 'CallSid': 123, 'DialCallSid': 'abc'
      pending
    end
    it "updates active_connection with remote_id" do
      post :connection_gather_prompt, 'CallSid': 123, 'DialCallSid': 'abc'
      pending
    end
    it "says a question to gather user response" do
      post :connection_gather_prompt, 'CallSid': 123, 'DialCallSid': 'abc'
      pending
    end
    it "renders a twilio gather with the proper action" do
      post :connection_gather_prompt, 'CallSid': 123, 'DialCallSid': 'abc'
      pending
    end
  end

  describe "POST connection_gather" do
    it "finds the correct connection" do
      post :connection_gather_prompt, 'CallSid': 123, 'Digits': 1, connection_id: 1
      expect(assigns[:active_connection]).
      pending
    end
    it "sets the correct connection state" do
      # allow
      post :connection_gather_prompt, 'CallSid': 123, 'Digits': 1, connection_id: 1
      pending

    end
    it "redirects to new_connection_path" do
      post :connection_gather_prompt, 'CallSid': 123, 'Digits': 1, connection_id: 1
      pending
    end
  end

end