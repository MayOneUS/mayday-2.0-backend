# == Schema Information
#
# Table name: people
#
#  id         :integer          not null, primary key
#  email      :string
#  phone      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

describe Person do
  let(:district) { FactoryGirl.create(:district) }
  let(:person)   { FactoryGirl.create(:person, district: district,
                                               state:    district.state,
                                               zip_code: '03431') }
  describe "#target_legislators" do
    let!(:campaign) { FactoryGirl.create(:campaign_with_reps, count: 6, priority: 1) }
    let!(:rep_with_us) { FactoryGirl.create(:representative, with_us: true, district: district) }
    let!(:unconvinced_senator) {FactoryGirl.create(:senator, with_us: false, state: district.state) }

    context "normal" do
      subject(:legislators) { person.target_legislators }

      it "returns local senator first" do
        expect(legislators.first).to eq unconvinced_senator
      end
      it "returns 5 legislators" do
        expect(legislators.count).to eq 5
      end

    end

    context "json" do
      subject(:legislators) { person.target_legislators(json: true) }
      
      it "returns local senator first" do
        expect(legislators.first['id']).to eq unconvinced_senator.id
      end
      it "sets local to true for local senator" do
        expect(legislators.first['local']).to be true
      end
      it "sets local to false for other targets" do
        expect(legislators.second['local']).to be false
      end
    end
  end

  describe "#update_location" do
    context "bad address" do
      it "doesn't change location" do
        expect {
          person.update_location(address: '2020 Oregon St', zip: 'bad')
        }.to_not change { person.location }
      end
    end

    context "good address" do
      let (:state)         { FactoryGirl.create(:state, abbrev: 'CA') }
      let!(:new_district)  { FactoryGirl.create(:district, state: state, district: '13') }

      before do
        person.update_location(address: '2020 Oregon St', zip: '94703')
      end

      it "sets address" do
        expect(person.address_1).to eq '2020 Oregon St'
      end
      it "sets district" do
        expect(person.district).to eq new_district
      end
      it "sets state" do
        expect(person.state).to eq state
      end
      it "sets zip" do
        expect(person.zip_code).to eq '94703'
      end
    end

    context "zip only" do
      context "same as zip already stored for person" do
        it "doesn't change location" do
          expect {
            person.update_location(zip: '03431')
          }.to_not change { person.location }
        end
      end

      context "different from zip already stored for person" do
        context "bad zip" do
          it "doesn't change location" do
            expect {
              person.update_location(zip: '999999')
            }.to_not change { person.location }
          end
        end
        context "zip found" do
          let!(:zip) { FactoryGirl.create(:zip_code, zip_code: '94703') }
          let!(:new_district)  { FactoryGirl.create(:district) }

          context "with multiple districts" do
            before do
              zip.districts = [district, new_district]
              person.update_location(zip: '94703')
            end

            it "clears address" do
              expect(person.address_1).to be_nil
            end
            it "clears district" do
              expect(person.district).to be_nil
            end
            it "sets state" do
              expect(person.state).to eq zip.state
            end
            it "sets zip" do
              expect(person.zip_code).to eq '94703'
            end
          end
          context "single district" do
            before do
              zip.districts = [new_district]
              person.update_location(zip: '94703')
            end

            it "clears address" do
              expect(person.address_1).to be_nil
            end
            it "sets district" do
              expect(person.district).to eq new_district
            end
            it "sets state" do
              expect(person.state).to eq zip.state
            end
            it "sets zip" do
              expect(person.zip_code).to eq '94703'
            end
          end
        end

        context "zip not found" do
          before do
            person.update_location(zip: '94703')
          end

          it "clears district" do
            expect(person.district).to be_nil
          end
          it "clears state" do
            expect(person.state).to be_nil
          end
          it "sets zip" do
            expect(person.zip_code).to eq '94703'
          end
        end
      end
    end
  end
end
