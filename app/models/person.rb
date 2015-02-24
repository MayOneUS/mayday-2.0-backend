class Person < ActiveRecord::Base
  has_many :locations
  has_one :current_location, -> { order 'created_at DESC' }, class_name: "Location"
  has_many :disricts, through: :locations
  has_one :current_district, through: :current_location, source: 'district'

  validates :email, uniqueness: true
end
