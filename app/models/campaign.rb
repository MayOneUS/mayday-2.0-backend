class Campaign < ActiveRecord::Base
  has_and_belongs_to_many :districts
  has_many :zip_codes, through: :districts

  validates :name, presence: true
end
