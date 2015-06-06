# == Schema Information
#
# Table name: activities
#
#  id          :integer          not null, primary key
#  name        :string
#  template_id :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sort_order  :integer
#

class Activity < ActiveRecord::Base
  has_many :actions
  validates :template_id, uniqueness: true

  DEFAULT_TEMPLATE_IDS = {
    rsvp: 'rsvp',
    call: 'call-congress'
    record: 'record-message'
  }
end
