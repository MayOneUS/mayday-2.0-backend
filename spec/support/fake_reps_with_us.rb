require 'sinatra/base'

class FakeRepsWithUs < Sinatra::Base

  get '/bills' do
    json_response 200, 'bills.json'
  end

  get "/legislators/:id" do
    case params[:id]
    when 'S001168'
      json_response 200, 'rep_with_us.json'
    when 'bad'
      json_response 404, 'not_found.html'
    else
      json_response 200, 'unconvinced_legislator.json'
    end
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/reps_with_us/' + file_name, 'rb').read
  end
end