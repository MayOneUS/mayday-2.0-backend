class State < ActiveRecord::Base
  has_many :districts
  has_many :zip_codes

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :abbrev, presence: true, uniqueness: { case_sensitive: false }

  def to_s
    abbrev
  end
end
