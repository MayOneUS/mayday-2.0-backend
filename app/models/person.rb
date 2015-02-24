class Person < ActiveRecord::Base
  has_one :location
  has_one :district, through: :location

  validates :email, uniqueness: true
end
