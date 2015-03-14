class V1::BlogPostsController < V1::BaseController
  def index
    render json: BlogFetcher.feed(param: :recent, reset: reset?)
  end

  def press_releases
    render json: BlogFetcher.feed(param: :press_releases, reset: reset?)
  end

  protected

  def reset?
    params[:reset] == "1"
  end
end
