class Target < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :legislator

  scope :top_priority, -> { where(priority: 1) }
end
