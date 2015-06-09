describe "Calls API" do
  it 'allows looping through' do
    call = FactoryGirl.create(:call)
    legislators = create_list(:representative, 10, :targeted, priority: 1)
    post "/ivr/calls/start", CallSid: call.remote_id
    5.times do |i|
      get "/ivr/calls/new_connection", CallSid: call.remote_id
      current_connection = call.last_connection
      post "/ivr/calls/connection_gather_prompt", CallSid: call.remote_id, DialCallSid: "dial_call_sid_#{i}"
      post "/ivr/calls/connection_gather", CallSid: call.remote_id, connection_id: current_connection.id, Digits: 1
    end

    get "/ivr/calls/new_connection", CallSid: call.remote_id
    xml = Oga.parse_xml(response.body)

    expect(xml.css('Play')).not_to match(/there_are_more/)
    expect(call.connections.map(&:legislator_id).uniq.length).to eq(6)
  end
end