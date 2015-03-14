class V1::BlogPostsController < V1::BaseController
  def index
    render json: BlogFetcher.feed(param: :recent, reset: parsed_reset)
  end

  def press_releases
    render json: BlogFetcher.feed(param: :press_releases, reset: parsed_reset)
  end

  protected

  def parsed_reset
    params[:reset].presence == "1"
  end
end
