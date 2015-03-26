# == Schema Information
#
# Table name: locations
#
#  id            :integer          not null, primary key
#  location_type :string
#  address_1     :string
#  address_2     :string
#  city          :string
#  state_id      :integer
#  zip_code      :string
#  person_id     :integer
#  district_id   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

describe Location do
  it "validates required associations" do
    location = Location.new
    location.valid?

    expect(location.errors).to have_key(:person)
  end

  describe "#update_location" do
    let(:location) { FactoryGirl.create(:location, zip_code: '03431') }
    context "with a bad address" do
      it "doesn't change location" do
        expect{
          location.update_location(address: '2020 Oregon St', zip: 'bad')
          }.not_to change{location.attributes}
      end
    end

    context "with a good address" do
      let (:state)    { FactoryGirl.create(:state, abbrev: 'CA') }
      let!(:district) { FactoryGirl.create(:district, state: state, district: '13') }

      before do
        location.update_location(address: '2020 Oregon St', zip: '94703')
      end

      it "sets address" do
        expect(location.address_1).to eq '2020 Oregon St'
      end
      it "sets district" do
        expect(location.district).to eq district
      end
      it "sets state" do
        expect(location.state).to eq state
      end
      it "sets zip" do
        expect(location.zip_code).to eq '94703'
      end
    end

    context "with zip only" do
      context "with same zip already stored" do
        it "doesn't change location" do
          original_attributes = location.attributes
          location.update_location(zip: '03431')
          expect(location.attributes).to eq original_attributes
        end
      end

      context "with different zip already stored" do
        context "for invalid zip" do
          it "doesn't change location" do
            original_attributes = location.attributes
            location.update_location(zip: '999999')
            expect(location.attributes).to eq original_attributes
          end
        end
        context "for zip found" do
          let!(:zip) { FactoryGirl.create(:zip_code, zip_code: '94703') }
          let!(:district) { FactoryGirl.create(:district) }

          context "with multiple districts" do
            before do
              zip.districts = [district, FactoryGirl.create(:district)]
              location.update_location(zip: '94703')
            end

            it "clears address" do
              expect(location.address_1).to be_nil
            end
            it "clears district" do
              expect(location.district).to be_nil
            end
            it "sets state" do
              expect(location.state).to eq zip.state
            end
            it "sets zip" do
              expect(location.zip_code).to eq '94703'
            end
          end
          context "with single district" do
            before do
              zip.districts = [district]
              location.update_location(zip: '94703')
            end

            it "clears address" do
              expect(location.address_1).to be_nil
            end
            it "sets district" do
              expect(location.district).to eq district
            end
            it "sets state" do
              expect(location.state).to eq zip.state
            end
            it "sets zip" do
              expect(location.zip_code).to eq '94703'
            end
          end
        end

        context "for zip not found" do
          before do
            allow(ZipCode).to receive(:find_by).and_return(nil)
          end

          it "clears district" do
            expect{
              location.update_location(zip: '94703')
            }.not_to change{location.district}
          end
          it "clears state" do
            expect{
              location.update_location(zip: '94703')
            }.not_to change{location.state}
          end
          it "sets zip" do
            expect{
              location.update_location(zip: '94703')
            }.not_to change{location.zip_code}
          end
        end
      end
    end
  end

  describe "#update_nation_builder" do
    let(:person) { FactoryGirl.create(:person, email: 'user@example.com') }
    let(:location_attributes) do
      {
        address_1:    nil,
        address_2:    nil,
        city:         'Keene',
        zip_code:     nil,
        state_abbrev: nil
      }.stringify_keys
    end
    context "creating new location" do
      it "sends call to update NationBuilder" do
        expect_any_instance_of(Location).to receive(:update_nation_builder).and_call_original
        expect(NbPersonPushAddressJob).to receive(:perform_later).
          with('user@example.com', location_attributes)
        person.create_location(city: 'Keene')
      end
    end
    context "updating existing location" do
      let(:location) { person.create_location(city: 'Berkeley') }
      before { expect(location).to receive(:update_nation_builder).and_call_original }

      it "sends call to update Nation if relevant field changed" do
        expect(NbPersonPushAddressJob).to receive(:perform_later).
          with('user@example.com', location_attributes)
        location.update(city: 'Keene')
      end

      it "doesn't send call to update Nation if no relevant field changed" do
        expect(NbPersonPushAddressJob).not_to receive(:perform_later)
        location.update(city: 'Berkeley')
      end
    end
  end
end
