class V1::BlogPostsController < V1::BaseController
  def index
    render json: BlogFetcher.feed(:recent)
  end

  def press_releases
    render json: BlogFetcher.feed(:press_releases)
  end
end
