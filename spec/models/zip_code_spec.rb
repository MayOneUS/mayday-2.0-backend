# == Schema Information
#
# Table name: zip_codes
#
#  id             :integer          not null, primary key
#  zip_code       :string
#  city           :string
#  state_id       :integer
#  district_count :integer
#  on_house_gov   :boolean
#  last_checked   :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

describe ZipCode do

  describe ".valid_zip_5" do
    it "accepts valid zip codes" do
      good_zips = %w[94703 950601234 05301-1234]
      results = good_zips.map {|zip| ZipCode.valid_zip_5(zip) }
      expect(results).to eq ["94703", "95060", "05301"]
    end

    it "rejects bad zip codes" do
      bad_zips = %w[1234 123456 12345-124]
      results = bad_zips.map {|zip| ZipCode.valid_zip_5(zip) }
      expect(results).to eq [nil, nil, nil]
    end
  end

end
