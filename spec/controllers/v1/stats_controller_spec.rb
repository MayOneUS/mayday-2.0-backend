require 'rails_helper'

describe V1::StatsController,  type: :controller do

  before(:all) do
    @target_counts = {:supporter_count=>2812, :volunteer_count=>43949, :called_voters_count=>0, :reps_calls_count=>0, :house_supporters=>0, :senate_supporters=>0, :donations_total=>748608206, :donations_count=>65136}
  end

  context 'with redis stored counts' do
    before(:all) do
     ExternalCountFetcher::REDIS_KEYS.each do |key|
      counter = Redis::Counter.new('external_count_fetcher:true:'+key.to_s)
      counter.value = @target_counts[key]
    end
    end
    after(:all){ Redis.new.flushdb }

    describe "GET index" do
      it "returns success" do
        get :index
        expect(response).to be_success
      end
      it "returns stored counts in json" do
        get :index
        expect_any_instance_of(ExternalCountFetcher).not_to receive(:fetch_empty_counts!)
        expect(response.body).to eq @target_counts.to_json
      end
    end
  end

  context 'without redis stored counts' do
    # after(:all){ Redis.new.flushdb }

    describe "GET index" do
      it "fetches external counts" do
        expect_any_instance_of(ExternalCountFetcher).to receive(:fetch_empty_counts!).and_call_original
        get :index
      end
    end
  end
end