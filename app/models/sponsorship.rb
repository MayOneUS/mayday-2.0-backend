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

  scope :sponsored,       -> { where.not(introduced_at: nil) }
  scope :cosponsored,     -> { where.not(cosponsored_at: nil) }
  scope :pledged_support, -> { where.not(pledged_support_at: nil) }
  scope :current,         -> { joins(:bill).merge(Bill.current) }
  scope :session, -> session { joins(:bill).merge(Bill.session(session)) }
  scope :chamber, -> chamber { joins(:bill).merge(Bill.chamber(chamber)) }
  scope :most_recent_activity, -> { order('GREATEST(cosponsored_at, introduced_at, pledged_support_at) DESC') }

  delegate :name, :congressional_session, to: :bill

  def current_sponsorship_level
    case
      when introduced_at then :sponsored
      when cosponsored_at then :cosponsored
      when pledged_support_at then :pledged_support
    end
  end

  def current_sponsorship_at
    introduced_at || cosponsored_at || pledged_support_at
  end

  private

  def serializable_hash(options)
    super({ methods: [:name, :congressional_session, :current_sponsorship_level,
                      :current_sponsorship_at],
            only: [] }.merge(options || {}))
  end
end
