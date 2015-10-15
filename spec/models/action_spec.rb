# == Schema Information
#
# Table name: actions
#
#  id              :integer          not null, primary key
#  person_id       :integer          not null
#  activity_id     :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  utm_source      :string
#  utm_medium      :string
#  utm_campaign    :string
#  source_url      :string
#  donation_amount :float
#

require 'rails_helper'

describe Action do

  describe 'scopes' do
    before(:all) do
      @main_activity = FactoryGirl.create(:activity)
      FactoryGirl.create_list(:action, 3, activity: @main_activity)
      Timecop.freeze(4.days.ago) do
        FactoryGirl.create_list(:action, 2)
      end
    end
    describe '#by_date' do
      it 'filters by start_at' do
        count = Action.by_date(3.days.ago).count
        expect(count).to eq(3)
      end
      it 'filters by start_at and end at' do
        count = Action.by_date(5.days.ago, 2.days.ago).count
        expect(count).to eq(2)
      end
    end
  end

end
