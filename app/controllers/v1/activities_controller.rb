class V1::ActivitiesController < V1::BaseController

  def index
    @activities = Activity.all
    logger.warn @activities
    render
  end

end