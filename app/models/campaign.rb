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
  has_and_belongs_to_many :legislators
  has_and_belongs_to_many :representatives, -> { house }, class_name: 'Legislator'
  has_and_belongs_to_many :senators, -> { senate }, class_name: 'Legislator'
  has_many :districts, through: :representatives
  has_many :zip_codes, through: :districts
  has_many :states, through: :senators

  validates :name, presence: true

  scope :active, -> { all } # need to implement active

  def active?
    true
  end
end
