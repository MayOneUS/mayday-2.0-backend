# == Schema Information
#
# Table name: ivr_calls
#
#  id                  :integer          not null, primary key
#  remote_id           :string
#  person_id           :integer
#  status              :string
#  duration            :integer
#  ended_at            :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  call_type           :string
#  remote_origin_phone :string
#  campaign_ref        :string
#  campaign_id         :integer
#

class Ivr::Call < ActiveRecord::Base
  has_many :connections, class_name: 'Ivr::Connection', dependent: :destroy
  has_many :recordings, class_name: 'Ivr::Recording', dependent: :destroy
  has_many :called_legislators, -> { merge(Ivr::Connection.completed) }, through: :connections, source: :legislator
  has_many :attempted_legislators, through: :connections, source: :legislator
  has_one :last_connection, -> { order 'created_at desc' }, class_name: 'Ivr::Connection'
  has_one :last_recording, -> { order 'created_at desc' }, class_name: 'Ivr::Recording'
  belongs_to :campaign
  belongs_to :person, required: true

  delegate :target_legislators, :all_called_legislators, to: :person

  before_create :set_default_campaign

  CALL_STATUSES = {
    completed: 'completed',
    no_answer: 'no-answer',
    busy:      'busy',
    canceled:  'canceled',
    failed:    'failed'
  }

  CONNECTION_LOOP_COUNT = 5

  def set_default_campaign
    self.campaign ||= Campaign.active_default
  end

  def create_connection!
    connections.create!(legislator: next_target)
  end

  def legislators_targeted
    target_legislators(campaign_id: campaign_id) - relevant_called_legislators - attempted_legislators
  end

  def relevant_called_legislators
    if campaign_id.nil?
      all_called_legislators
    else
      all_called_legislators.where(ivr_calls: {campaign_id: campaign_id})
    end
  end

  def next_target
    legislators_targeted.first
  end

  def encouraging_count
    (connections.length % Ivr::Call::CONNECTION_LOOP_COUNT)
  end

  def finished_loop?
    (connections.length > 0) && connections.length % Ivr::Call::CONNECTION_LOOP_COUNT == 0
  end

end
