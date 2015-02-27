require 'rails_helper'

describe Location do
  let(:district) { FactoryGirl.create(:district) }
  let(:person)   { FactoryGirl.create(:person, district: district,
                                               state:    district.state,
                                               zip_code: '03431') }
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