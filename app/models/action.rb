# == Schema Information
#
# Table name: actions
#
#  id          :integer          not null, primary key
#  person_id   :integer          not null
#  activity_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Action < ActiveRecord::Base
  belongs_to :person, required: true
  belongs_to :activity, required: true
end
