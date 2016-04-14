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
  describe "#single_district?" do
    it "returns true if zip code has 1 district" do
      zip = ZipCode.new
      zip.districts << District.new

      result = zip.single_district?

      expect(result).to be true
    end

    it "returns false if zip code has no districts" do
      zip = ZipCode.new

      result = zip.single_district?

      expect(result).to be false
    end

    it "returns false if zip code has multiple districts" do
      zip = ZipCode.new
      zip.districts << [District.new, District.new]

      result = zip.single_district?

      expect(result).to be false
    end
  end

  describe "#single_district" do
    it "returns district if zip code has 1 district" do
      zip = ZipCode.new
      district = District.new
      zip.districts << district

      result = zip.single_district

      expect(result).to eq district
    end

    it "returns nil if zip code has multiple districts" do
      zip = ZipCode.new
      zip.districts << [District.new, District.new]

      result = zip.single_district

      expect(result).to be nil
    end
  end
end
