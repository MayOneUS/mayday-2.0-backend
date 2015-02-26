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
  has_many :targets
  has_many :legislators, through: :targets
  has_many :districts,   through: :representatives
  has_many :zip_codes,   through: :districts
  has_many :states,      through: :senators

  validates :name, presence: true

  scope :active, -> { where(ended_at: nil) }

  def active?
    ended_at.blank?
  end
end
