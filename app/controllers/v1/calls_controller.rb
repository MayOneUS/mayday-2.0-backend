class V1::CallsController < V1::BaseController

  def create
    new_call = Integration::Twilio.initiate_congress_calling(phone: params[:phone])
    render json: new_call, status: 200
  end

end
