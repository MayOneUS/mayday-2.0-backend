require 'rails_helper'

describe V1::StatsController,  type: :controller do

  before(:all) do
    @fake_counts = {supporter_count: 69087, volunteer_count: 2151, called_voters_count: 0, reps_calls_count: 0,
      house_supporters: 0, senate_supporters: 0, donations_total: 748608206, donations_count: 65136,
      letter_signers: 1, recordings_uniq: 10, recordings_total: 20}
  end

  before do
    allow(Activity).to receive_message_chain(:find_by_template_id,:actions,:count).and_return(@fake_counts[:letter_signers])
    allow(Person).to receive_message_chain(:joins,:uniq,:count).and_return(@fake_counts[:recordings_uniq])
    allow(Person).to receive_message_chain(:joins,:count).and_return(@fake_counts[:recordings_total])
  end

  context 'with redis stored counts' do
    before(:all) do
     ExternalCountFetcher::REDIS_KEYS.each do |key|
      counter = Redis::Counter.new('external_count_fetcher:true:'+key.to_s)
      counter.value = @fake_counts[key]
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
        expect(response.body).to eq @fake_counts.to_json
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