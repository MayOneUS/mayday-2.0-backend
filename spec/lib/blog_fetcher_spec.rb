require 'rails_helper'

describe BlogFetcher do
  describe ".feed" do
    context "nothing cached" do
      it "fetches requested feed" do
        redis = Redis.new
        expect(RestClient).to receive(:get)
          .with(BlogFetcher::BASE_URL + BlogFetcher::ENDPOINTS[:recent])
        BlogFetcher.feed(param: :recent)
        expect(redis.ttl("#{BlogFetcher::KEY_BASE}:recent"))
          .to be_within(1).of(BlogFetcher::EXPIRE_SECONDS)
      end
    end

    context "feed already cached" do
      it "returns feed from cache" do
        redis = Redis.new
        redis.set("#{BlogFetcher::KEY_BASE}:recent", 'foo')
        expect(RestClient).not_to receive(:get)
        BlogFetcher.feed(param: :recent)
      end
    end
  end
end
