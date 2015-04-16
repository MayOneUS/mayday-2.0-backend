class Activity < ActiveRecord::Base
  has_many :actions
  validates :template_id, uniqueness: true
end
