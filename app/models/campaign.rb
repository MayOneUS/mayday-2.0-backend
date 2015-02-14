# == Schema Information
#
# Table name: campaigns
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Campaign < ActiveRecord::Base
  has_and_belongs_to_many :districts
  has_many :zip_codes, through: :districts

  validates :name, presence: true

  scope :active, -> { all } # need to implement active

  def active?
    true
  end
end
