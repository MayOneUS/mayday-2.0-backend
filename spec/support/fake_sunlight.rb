require 'sinatra/base'

class FakeSunlight < Sinatra::Base

  get Integration::Sunlight::LEGISLATORS_ENDPOINT do
    if params[:district].presence && params[:senate_class].presence
      file = 'not_found.json'
    elsif params[:senate_class].presence
      file = 'found_senator.json'
    elsif params[:district].presence
      file = 'found_rep.json'
    else
      file = 'multiple_results.json'
    end
    json_response 200, file
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/sunlight/' + file_name, 'rb').read
  end
end