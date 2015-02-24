class Person < ActiveRecord::Base
  has_one :location
  has_one :district

  validates :email, uniqueness: true
end
