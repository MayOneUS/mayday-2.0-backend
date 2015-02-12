# == Schema Information
#
# Table name: districts
#
#  id         :integer          not null, primary key
#  district   :string
#  state_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class District < ActiveRecord::Base
  belongs_to :state
  has_and_belongs_to_many :zip_codes
  has_and_belongs_to_many :campaigns

  validates :state, presence: true
  validates :district, uniqueness: { scope: :state }

  def to_s
    state.abbrev + district
  end

  def targeted_by_campaign?(campaign)
    campaigns.include?(campaign)
  end
end
