# == Schema Information
#
# Table name: sponsorships
#
#  id                 :integer          not null, primary key
#  bill_id            :integer          not null
#  legislator_id      :integer          not null
#  pledged_support_at :datetime
#  cosponsored_at     :datetime
#  introduced_at      :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Sponsorship < ActiveRecord::Base
  belongs_to :bill, required: true
  belongs_to :legislator, required: true

  scope :sponsored,   -> { where.not(introduced_at: nil) }
  scope :cosponsored, -> { where.not(cosponsored_at: nil) }
end
