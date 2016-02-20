# == Schema Information
#
# Table name: activities
#
#  id            :integer          not null, primary key
#  name          :string
#  template_id   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sort_order    :integer
#  activity_type :string
#

class Activity < ActiveRecord::Base
  has_many :actions
  validates :template_id, uniqueness: true

  DEFAULT_TEMPLATE_IDS = {
    rsvp: 'rsvp',
    call_congress: 'call-congress',
    record_message: 'record-message',
    donate: 'donate'
  }

  def donations_total_in_cents
    actions.sum(:donation_amount_in_cents)
  end

  def strike_total_in_cents
    actions.sum(:strike_amount_in_cents)
  end
end
