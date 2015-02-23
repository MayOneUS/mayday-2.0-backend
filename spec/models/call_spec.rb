# == Schema Information
#
# Table name: calls
#
#  id           :integer          not null, primary key
#  remote_id    :string
#  district_id  :integer
#  phone_origin :integer
#  state        :string
#  ended_at     :datetime
#  source       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Call, type: :model do
  describe "#targeted_legislators" do
    pending
  end
  describe "#called_legislators" do
    pending
  end
  describe "#random_target" do
    pending
  end
end
