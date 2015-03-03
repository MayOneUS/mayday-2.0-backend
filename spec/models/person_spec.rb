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
  describe "#target_legislators" do
    let(:district) { FactoryGirl.create(:district) }
    let(:person)   { FactoryGirl.create(:person, district: district,
                                                 state:    district.state,
                                                 zip_code: '03431') }
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

  describe "#update_nation_builder" do
    context "creating new user" do
      it "sends call to update NationBuilder" do
        expect_any_instance_of(Person).to receive(:update_nation_builder).and_call_original
        expect(Integration::NationBuilder).to receive(:create_or_update_person)
          .with({:attributes=>{"email"=>"user@example.com", "phone"=>"510-555-1234"}})
        FactoryGirl.create(:person, email: 'user@example.com', phone:'510-555-1234')
      end
    end
    context "updating existing user" do
      let(:user) { FactoryGirl.create(:person, email: 'user@example.com', phone:'510-555-1234') }
      before { expect(user).to receive(:update_nation_builder).and_call_original }
      
      it "sends call to update Nation if relevant field changed" do
        expect(Integration::NationBuilder).to receive(:create_or_update_person)
          .with({:attributes=>{"email"=>"user@example.com", "phone"=>"510-555-9999"}})
        user.update(phone:'510-555-9999')
      end
      
      it "doesn't send call to update Nation if no relevant field changed" do
        expect(Integration::NationBuilder).not_to receive(:create_or_update_person)
        user.update(phone:'510-555-1234')
      end
    end
  end
end
