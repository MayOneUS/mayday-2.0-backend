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

  def create_person_and_action(default_template_id: nil)
    person_params = params.require(:person).permit(:uuid, :email, :phone, :zip)
    action_params = params.permit(:template_id, :utm_source, :utm_medium, :utm_campaign, :source_url)
    action_params[:template_id] ||= default_template_id

    person = Person.create_or_update(person_params)
    person.create_action(action_params.symbolize_keys)

    person
  end

end
