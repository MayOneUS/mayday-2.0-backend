class V1::PeopleController < V1::BaseController

  def create
    person = Integration::NationBuilder.create_or_update_person(attributes: params[:person])
    render json: {id: person['id']}, status: 200
  end

end
