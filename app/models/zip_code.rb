class ZipCode < ActiveRecord::Base
  belongs_to :state
  has_and_belongs_to_many :districts
  has_many :campaigns, through: :districts

  validates :state, presence: true
  validates :zip_code, presence: true, uniqueness: { case_sensitive: false },
      format: { with: /\A\d{5}\z/ }

  def single_district?
    districts.size == 1
  end

  def single_district
    districts.first if single_district?
  end

  def targeted_by_campaign?(campaign)
    campaigns.include?(campaign)
  end

end
