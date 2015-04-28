# == Schema Information
#
# Table name: bills
#
#  id                    :integer          not null, primary key
#  bill_id               :string
#  chamber               :string
#  short_title           :string
#  summary_short         :string
#  congressional_session :integer
#  opencongress_url      :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class Bill < ActiveRecord::Base
  has_many :sponsorships, dependent: :delete_all
  has_many :supporters, through: :sponsorships, source: :legislator
  has_many :cosponsors, -> { merge(Sponsorship.cosponsored) }, through: :sponsorships, source: :legislator
  has_one :authorship, -> { merge(Sponsorship.sponsored) }, class_name: 'Sponsorship'
  has_one :sponsor, through: :authorship, source: :legislator

  validates :bill_id, uniqueness: true

  CURRENT_SESSION = 114 # better way to handle this?
  TRACKED_BILL_IDS = %w[hr20-114 hr424-114]

  scope :current, -> { where(congressional_session: CURRENT_SESSION) }

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
    sponsorships.where.not(cosponsored_at: nil).delete_all # To do: update rather than delete?
    cosponsors.each do |sponsorship|
      if cosponsor = Legislator.find_by(bioguide_id: sponsorship[:sponsor_id])
        sponsorships.create(legislator: cosponsor, cosponsored_at: sponsorship[:cosponsored_at])
      end
    end
  end

  def timeline
    running_count = 1 # sponsor
    sponsorships.where.not(cosponsored_at: nil).order('DATE(cosponsored_at)')
                .group('DATE(cosponsored_at)').count.map do |date, count|
      running_count += count
      [date, running_count]
    end
  end

  def supporter_count
    sponsorships.size
  end

  def cosponsor_count
    cosponsors.size
  end

  def needed_cosponsor_count
    (chamber_size / 2.0).ceil - cosponsor_count
  end

  def chamber_size
    Legislator.where(chamber: chamber).in_office.count # need to remove extra states or this will return 439
  end

  def name
    short_title || official_title
  end
end
