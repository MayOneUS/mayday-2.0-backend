# == Schema Information
#
# Table name: actions
#
#  id           :integer          not null, primary key
#  person_id    :integer          not null
#  activity_id  :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  utm_source   :string
#  utm_medium   :string
#  utm_campaign :string
#  source_url   :string
#

class Action < ActiveRecord::Base
  belongs_to :person, required: true
  belongs_to :activity, required: true
end
