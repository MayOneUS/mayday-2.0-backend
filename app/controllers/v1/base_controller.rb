class V1::BaseController < ApplicationController

  protected

  def rescue_error_messages
    begin
      response = yield
      [response, 200]
    rescue ArgumentError, OAuth2::Error => e
      [{error: e.message}, 422]
    end
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { error: "#{exception.param} is required" }, status: 422
  end

end
