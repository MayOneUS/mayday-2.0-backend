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

end
