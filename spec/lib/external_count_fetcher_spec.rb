require 'rails_helper'

describe ExternalCountFetcher do
  before(:all) do
    @expected_counts = {"donations_count"=>"65136", "donations_total"=>"748608206", "volunteer_count"=>"43949", "supporter_count"=>"2812"}
  end

  describe "#fetch_all!" do
    it "fetches all" do
      expect_any_instance_of(ExternalCountFetcher).to receive(:fetch_donations_total).and_call_original
      expect_any_instance_of(ExternalCountFetcher).to receive(:fetch_donations_count).and_call_original
      expect_any_instance_of(ExternalCountFetcher).to receive(:fetch_supporter_counts).and_call_original
      ExternalCountFetcher.new.fetch_all!
    end
    it "returns counts hash" do
      expect(ExternalCountFetcher.new.fetch_all!).to eq(@expected_counts)
    end
  end

  describe "#counts" do
    context "with empty redis counter cache" do
      it "calls fetch_all!" do
        expect_any_instance_of(ExternalCountFetcher).to receive(:fetch_all!).and_call_original
        ExternalCountFetcher.new.counts
      end
      it "returns counts hash" do
        expect(ExternalCountFetcher.new.counts).to eq(@expected_counts)
      end
    end
    context "with full redis counter cache" do
      before do
        counter = Redis::HashKey.new('external_counts', :expiration => 3.hours)
        counter.bulk_set @expected_counts
      end
      it "doesn't fetch_all! when counter_hash has any" do
        expect_any_instance_of(ExternalCountFetcher).not_to receive(:fetch_all!)
        ExternalCountFetcher.new.counts
      end
      it "returns counts hash" do
        expect(ExternalCountFetcher.new.counts).to eq(@expected_counts)
      end
    end
  end

end