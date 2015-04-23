class Bill < ActiveRecord::Base
  has_many :sponsorships
  has_many :cosponsors, -> { merge(Sponsorship.cosponsored) }, through: :sponsorships, source: :legislator
  has_one :authorship, -> { merge(Sponsorship.sponsored) }, class_name: 'Sponsorship'
  has_one :sponsor, through: :authorship, source: :legislator

  validates :bill_id, uniqueness: true

  def self.fetch(bill_id:)
    if results = Integration::Sunlight.get_bill(bill_id:  bill_id)
      create_or_update(results.deep_symbolize_keys)
    end
  end

  def self.create_or_update(hash)
    bill_id       = hash.delete(:bill_id)
    sponsor_id    = hash.delete(:sponsor_id)
    introduced_at = hash.delete(:introduced_at)
    cosponsors    = hash.delete(:cosponsors) || []
    bill = find_or_initialize_by(bill_id: bill_id).tap{|b| b.update(hash)}
    bill.update_sponsor(bioguide_id: sponsor_id, date: introduced_at)
    bill.update_cosponsors(cosponsors)
    bill
  end

  def update_sponsor(bioguide_id:, date:)
    sponsorships.where.not(introduced_at: nil).delete_all
    if sponsor = Legislator.find_by(bioguide_id: bioguide_id)
      sponsorships.create(legislator: sponsor, introduced_at: date)
    end
  end

  def update_cosponsors(cosponsors)
    sponsorships.where.not(cosponsored_at: nil).delete_all
    cosponsors.each do |sponsorship|
      if cosponsor = Legislator.find_by(bioguide_id: sponsorship[:sponsor_id])
        sponsorships.create(legislator: cosponsor, cosponsored_at: sponsorship[:cosponsored_at])
      end
    end
  end
end
