require 'sinatra/base'

class FakeMobileCommons < Sinatra::Base

  get '/districts/lookup.json' do
    if (params[:lat] == 'bad' || params[:lat] == '45.42179')
      file = 'district_lookup_not_found.json'
    elsif params[:lat] == 'vt'
      file = 'district_lookup_found_at_large.json'
    else
      file = 'district_lookup_found.json'
    end
    json_response 200, file
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/mobile_commons/' + file_name, 'rb').read
  end
end