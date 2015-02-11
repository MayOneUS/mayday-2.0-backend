require 'rails_helper'

describe Integration::Here do

  describe "#geocode_address" do
    context "good address" do
      let(:response) do
        Integration::Here.geocode_address( address:'2020 Oregon St', 
                                           city:   'Berkeley', 
                                           state:  'CA', 
                                           zip:    '94703' )
      end

      it "returns address" do 
        expect(response[:address_name]).to eq '2020 Oregon St, Berkeley, CA 94703, United States'
      end

      it "returns coordinates" do 
        expect(response[:coordinates]).to eq [37.8570709, -122.2673874]
      end

      it "returns full confidence" do
        expect(response[:confidence]).to eq 1
      end
    end

    context "insufficitent address" do
      let(:response) do
        Integration::Here.geocode_address(address: '2020 Oregon St')
      end

      it "returns address" do 
        expect(response[:address_name]).to eq 'Oregon St, Fall River, MA 02720, United States'
      end

      it "returns moderate confidence" do
        expect(response[:confidence]).to be_between(0, 1).exclusive
      end
    end

    context "bad address" do
      let(:response) do
        Integration::Here.geocode_address(address: '2020 Oregon St', zip: 'bad')
      end

      it "returns no address" do 
        expect(response[:address_name]).to be_nil
      end

      it "returns no confidence" do
        expect(response[:confidence]).to eq 0
      end
    end
  end
end