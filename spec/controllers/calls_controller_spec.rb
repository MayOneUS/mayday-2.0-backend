require 'rails_helper'

describe CallsController,  type: :controller do

  def setup_active_call_double(target_legislators:[])
    @active_call = double('active_call')
    allow(@active_call).to receive(:target_legislators).and_return(target_legislators)
    allow(Ivr::Call).to receive_message_chain(:includes, :where, :first_or_create).and_return(@active_call)
  end

  describe "GET start" do
    it "redirects to new_connection" do
      get :start, 'CallSid': 123
      xml_response = Oga.parse_xml(response.body)

      expect(response).to be_success
      expect(xml_response.css('Redirect')).to be_present
      expect(xml_response.css('Redirect').attribute('method')[0].value).to eq('get')
      expect(xml_response.css('Redirect').text).to eq(calls_new_connection_url)
    end
  end

  describe "GET new_connection" do
    context "with a target" do
      before do
        legislator = double('legislator')
        @phone = '555-555-5555'
        allow(legislator).to receive(:phone).and_return(@phone)
        setup_active_call_double(target_legislators: [legislator])
        allow(@active_call).to receive(:next_target).and_return(legislator)

        @connection = double('connection')
        allow(@active_call).to receive(:create_connection!).and_return(@connection)
        allow(@connection).to receive(:legislator).and_return(legislator)
      end
      it "dials the right number" do
        get :new_connection, 'CallSid': 123
        xml_response = Oga.parse_xml(response.body)
        expect(xml_response.css('Dial').text).to eq(@phone)
      end
      it "creates a new connection" do
        get :new_connection, 'CallSid': 123
        expect(@active_call).to have_received(:create_connection!)
      end
    end
    context "with completed targets" do
      before do
        setup_active_call_double
        allow(@active_call).to receive_message_chain(:connections, :size).and_return(5)
        allow(@active_call).to receive(:next_target).and_return(nil)
      end
      it "says sorry" do
        get :new_connection, 'CallSid': 123
        target_text = Oga.parse_xml(response.body).css('Play').text
        expect(target_text).to match(/closing_message/)
        expect(target_text).to match(/goodbye/)
      end
      it "hangs up" do
        get :new_connection, 'CallSid': 123
        xml_response = Oga.parse_xml(response.body)
        expect(xml_response.css('Hangup')).to be_present
      end
    end
    context "with no target" do
      before do
        setup_active_call_double
        allow(@active_call).to receive_message_chain(:connections, :size).and_return(0)
        allow(@active_call).to receive(:next_target).and_return(nil)
      end
      it "says sorry" do
        get :new_connection, 'CallSid': 123
        target_text = Oga.parse_xml(response.body).css('Play').text
        expect(target_text).to match(/no_targets/)
        expect(target_text).to match(/goodbye/)
      end
      it "hangs up" do
        get :new_connection, 'CallSid': 123
        xml_response = Oga.parse_xml(response.body)
        expect(xml_response.css('Hangup')).to be_present
      end
    end
  end

  describe "POST connection_gather_prompt" do
    before do
      setup_active_call_double
      @last_connection = double('last_connection')
      allow(@active_call).to receive(:last_connection).and_return(@last_connection)
      allow(@last_connection).to receive(:update)
      allow(@last_connection).to receive(:id).and_return(123)
    end
    it "updates active_connection with remote_id" do
      post :connection_gather_prompt, 'CallSid': 123, 'DialCallSid': 'abc'

      expect(@last_connection).to have_received(:update).with({:remote_id=>"abc"})
    end
    it "says a question to gather user response" do
      post :connection_gather_prompt, 'CallSid': 123, 'DialCallSid': 'abc'
      xml_response = Oga.parse_xml(response.body)

      expect(xml_response.css('Play').text).to match(/user_response/)
    end
    it "renders a twilio gather with the proper action" do
      post :connection_gather_prompt, 'CallSid': 123, 'DialCallSid': 'abc'
      xml_response = Oga.parse_xml(response.body)

      action_url = xml_response.css('Gather').attribute('action')[0].value
      expected_url = calls_connection_gather_url(connection_id: @last_connection.id)
      expect(action_url).to eq(expected_url)
    end
  end

  describe "POST connection_gather" do
    before do
      @connection = double('connection')
      allow(Ivr::Connection).to receive(:find).and_return(@connection)
      allow(@connection).to receive(:update)
      setup_active_call_double
      allow(@active_call).to receive_message_chain(:connections, :size).and_return(1)
    end
    it "finds the correct connection" do
      post :connection_gather, 'CallSid': 123, 'Digits': 1, connection_id: 1
      expect(Ivr::Connection).to have_received(:find).with('1')
    end
    it "sets the correct connection status" do
      post :connection_gather, 'CallSid': 123, 'Digits': 1, connection_id: 1
      expect(@connection).to have_received(:update).with(status_from_user: Ivr::Connection::USER_RESPONSE_CODES['1'])
    end
    it "plays an encouraging message" do
      allow(@active_call).to receive_message_chain(:connections, :size).and_return(3)
      allow(AudioFileFetcher).to receive(:file_for_key)
      post :connection_gather, 'CallSid': 123, 'Digits': 1, connection_id: 1

      xml_response = Oga.parse_xml(response.body)
      expect(xml_response.css('Play')).to be_present
      expect(AudioFileFetcher).to have_received(:file_for_key).with('encouraging_3')
    end
    it "redirects to new_connection_path" do
      post :connection_gather, 'CallSid': 123, 'Digits': 1, connection_id: 1
      xml_response = Oga.parse_xml(response.body)

      expect(xml_response.css('Redirect').attribute('method')[0].value).to eq('get')
      expect(xml_response.css('Redirect').text).to eq(calls_new_connection_url)
    end
  end

end