# == Schema Information
#
# Table name: calls
#
#  id         :integer          not null, primary key
#  remote_id  :string
#  person_id  :integer
#  status     :string
#  duration   :integer
#  ended_at   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Ivr::Call < ActiveRecord::Base
  has_many :connections, class_name: 'Ivr::Connection', dependent: :destroy
  has_many :called_legislators, -> { merge(Ivr::Connection.completed) }, through: :connections, source: :legislator
  has_many :attempted_legislators, through: :connections, source: :legislator
  has_one :last_connection, -> { order 'created_at desc' }, class_name: 'Ivr::Connection'
  belongs_to :person, required: true

  delegate :target_legislators, :all_called_legislators, to: :person

  CALL_STATUSES = {
    completed: 'completed',
    no_answer: 'no-answer',
    busy:      'busy',
    canceled:  'canceled',
    failed:    'failed'
  }

  CONNECTION_LOOP_COUNT = 5

  def create_connection!
    connections.create!(legislator: next_target)
  end

  def legislators_targeted
    target_legislators - all_called_legislators - attempted_legislators
  end

  def next_target
    legislators_targeted.first
  end

  def encouraging_count
    (connections.length % Ivr::Call::CONNECTION_LOOP_COUNT)+1
  end

  def finished_loop?
    (connections.length > 0) && connections.length % Ivr::Call::CONNECTION_LOOP_COUNT == 0
  end

end