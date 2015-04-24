class Sponsorship < ActiveRecord::Base
  belongs_to :bill, required: true
  belongs_to :legislator, required: true

  scope :sponsored,   -> { where.not(introduced_at: nil) }
  scope :cosponsored, -> { where.not(cosponsored_at: nil) }
end
