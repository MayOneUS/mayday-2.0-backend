# == Schema Information
#
# Table name: campaigns
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ended_at   :datetime
#  is_default :boolean
#

require 'rails_helper'

describe Campaign do
  describe "validations" do
    it "validates only one campaign can be default" do
      FactoryGirl.create(:campaign, is_default: true)
      campaign = FactoryGirl.build(:campaign, is_default: true)
      expect(campaign.valid?).to be false
    end
  end

end
