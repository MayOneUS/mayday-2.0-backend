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

  delegate :name, :congressional_session, to: :bill

  SPONSORSHIP_LEVELS = [
    [:introduced_at, 'sponsored'],
    [:cosponsored_at, 'cosponsored'],
    [:pledged_support_at, 'pledged_support']
  ]

  def current_sponsorship
    SPONSORSHIP_LEVELS.each do |field_name, level|
      if date = send(field_name)
        return [date, level]
      end
    end
    [nil, nil]
  end

  def current_sponsorship_level
    current_sponsorship[1]
  end

  def current_sponsorship_at
    current_sponsorship[0]
  end

  private

  def serializable_hash(options)
    super({ methods: [:name, :congressional_session, :current_sponsorship_level,
                      :current_sponsorship_at],
            only:[] }.merge(options || {}))
  end
end
