class ZipCode < ActiveRecord::Base
  belongs_to :state
  has_and_belongs_to_many :districts
  has_many :campaigns, through: :districts

  validates :zip_code, presence: true, uniqueness: { case_sensitive: false },
      format: { with: /\A\d{5}\z/ }
end
