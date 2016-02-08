# spec/support/fake_nation_builder.rb
require 'sinatra/base'

class FakeNationBuilder < Sinatra::Base

  get '/supporter_counts_for_website' do
    json_response 200, 'lists.json'
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/nation_builder/' + file_name, 'rb').read
  end
end
