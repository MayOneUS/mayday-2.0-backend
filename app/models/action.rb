# == Schema Information
#
# Table name: actions
#
#  id              :integer          not null, primary key
#  person_id       :integer          not null
#  activity_id     :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  utm_source      :string
#  utm_medium      :string
#  utm_campaign    :string
#  source_url      :string
#  donation_amount :float
#

class Action < ActiveRecord::Base
  belongs_to :person, required: true
  belongs_to :activity, required: true
  belongs_to :donation_page

  scope :by_type, ->(activity_type) { joins(:activity).where('activities.activity_type' => activity_type) }
  scope :by_date, ->(start_at, end_at=nil) { where("created_at >= ? AND created_at <= ?", start_at, end_at || Time.now) }
end
