# spec/support/fake_github.rb
require 'sinatra/base'

class FakePledgeService < Sinatra::Base

  get '/r/total' do
    json_response 200, {"totalCents": 748608206}.to_json
  end

  get '/r/num_pledges' do
    json_response 200, {"count": 65136}.to_json
  end

  private

  def json_response(response_code, json)
    content_type :json
    status response_code
    json
  end
end