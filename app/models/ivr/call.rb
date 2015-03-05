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
  has_many :connections, class_name: 'Ivr::Connection'
  has_many :called_legislators, -> { merge(Ivr::Connection.completed) }, through: :connections, source: :legislator
  has_one :last_connection, -> { order 'created_at desc' }, class_name: 'Ivr::Connection'
  belongs_to :person, required: true

  delegate :target_legislators, :next_target, to: :person

  CALL_STATUSES = {
    completed: 'completed',
    no_answer: 'no-answer',
    busy:      'busy',
    canceled:  'canceled',
    failed:    'failed'
  }

  MAXIMUM_CONNECTIONS = 5

  def create_connection!
    connections.create(legislator: next_target)
  end

  def exceeded_max_connections?
    connections.size >= Ivr::Call::MAXIMUM_CONNECTIONS
  end

end