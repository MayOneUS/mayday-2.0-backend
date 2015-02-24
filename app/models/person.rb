class Person < ActiveRecord::Base
  has_one :location
  has_one :district, through: :location

  validates :email, presence: true, uniqueness: { case_sensitive: false }
end
