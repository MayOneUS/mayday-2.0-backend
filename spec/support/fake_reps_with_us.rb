require 'sinatra/base'

class FakeRepsWithUs < Sinatra::Base

  get '/bills' do
    json_response 200, 'bills.json'
  end

  get "/legislators/:id" do
    file = case params[:id]
           when 'S001168'
             'rep_with_us.json'
           when 'bad'
             'not_found.html'
           else
             'unconvinced_legislator.json'
           end

    json_response 200, file
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/reps_with_us/' + file_name, 'rb').read
  end
end