require 'rails_helper'

describe V1::StatsController,  type: :controller do

  before(:all) do
    @target_counts = {"donations_count"=>"65136", "donations_total"=>"748608206", "volunteer_count"=>"43949", "supporter_count"=>"2812"}
  end

  context 'with redis stored counts' do
    before(:all) do
      @counts = Redis::HashKey.new('external_counts', :expiration => 3.hours)
      @counts.bulk_set @target_counts
    end
    after(:all){ Redis.new.flushdb }

    describe "GET index" do
      it "returns success" do
        get :index
        expect(response).to be_success
      end
      it "returns stored counts in json" do
        get :index
        expect(response.body).to eq @target_counts.to_json
      end
    end
  end

  context 'without redis stored counts' do
    # after(:all){ Redis.new.flushdb }

    describe "GET index" do
      it "fetches external counts" do
        expect_any_instance_of(ExternalCountFetcher).to receive(:fetch_all!).and_call_original
        get :index
      end
    end
  end
end