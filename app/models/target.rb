class Target < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :legislator
end
