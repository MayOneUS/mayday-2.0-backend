require 'sinatra/base'

class FakeSunlight < Sinatra::Base

  get Integration::Sunlight::LEGISLATORS_ENDPOINT do
    file = if params[:district].presence && params[:senate_class].presence
             'not_found'
           elsif params[:senate_class].presence || params[:bioguide_id] == 'F000062'
             'found_senator'
           elsif params[:district].presence || params[:bioguide_id] == 'L000551'
             'found_rep'
           elsif params[:state] == 'badkey'
             'bad_key'
           else
             'multiple_results'
           end
    json_response 200, file
  end

  private

  def json_response(response_code, file_name)
    content_type :json
    status response_code
    File.open(File.dirname(__FILE__) + '/fixtures/sunlight/' + file_name + '.json', 'rb').read
  end
end