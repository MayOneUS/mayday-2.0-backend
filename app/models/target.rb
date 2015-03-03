# == Schema Information
#
# Table name: targets
#
#  id            :integer          not null, primary key
#  campaign_id   :integer
#  legislator_id :integer
#  priority      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Target < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :legislator

  scope :top_priority, -> { where(priority: 1) }
end
