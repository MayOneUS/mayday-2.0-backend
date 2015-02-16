require 'sinatra/base'

class FakeHere < Sinatra::Base

  get '/6.2/geocode.json' do
    if params[:postalcode] == ''
      file = 'geocoder_house_number_bad.json'
    elsif params[:postalcode] == 'bad'
      file = 'geocoder_address_not_found.json'
    elsif params[:postalcode] == 'canada'
      file = 'geocoder_canada.json'
    else
      file = 'geocoder_house_number.json'
    end
    json_response 200, file
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/here/' + file_name, 'rb').read
  end
end