# == Schema Information
#
# Table name: ivr_recordings
#
#  id            :integer          not null, primary key
#  duration      :integer
#  recording_url :string
#  state         :string
#  call_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe Ivr::Recording, type: :model do

  describe ".uniq_count" do
    it "properly counts uniq recordings per campaign_ref" do
      person_1 = FactoryGirl.create(:person)
      person_2 = FactoryGirl.create(:person)

      call_1 = FactoryGirl.create(:call, person: person_1, campaign_ref: 'first_ref')
      call_2 = FactoryGirl.create(:call, person: person_1, campaign_ref: 'first_ref')
      call_3 = FactoryGirl.create(:call, person: person_2, campaign_ref: 'first_ref')
      call_4 = FactoryGirl.create(:call, person: person_2, campaign_ref: 'second_ref')

      FactoryGirl.create(:ivr_recording, call: call_1)
      FactoryGirl.create_list(:ivr_recording, 2, call: call_2)
      FactoryGirl.create_list(:ivr_recording, 2, call: call_3)
      FactoryGirl.create(:ivr_recording, call: call_4)

      expect(Ivr::Recording.uniq_count).to eq(3)
    end
  end

end
