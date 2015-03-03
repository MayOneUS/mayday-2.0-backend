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

class Call < ActiveRecord::Base
  has_many :connections
  has_one :last_connection, -> { order 'created_at desc' }, class_name: 'Connection'
  belongs_to :person, required: true

  delegate :target_legislators, to: :person

  CALL_STATUSES = {
    completed: 'completed',
    no_answer: 'no-answer',
    busy:      'busy',
    canceled:  'canceled',
    failed:    'failed'
  }

  def create_connection!
    connections.create(legislator: next_target)
  end

  def called_legislators
    connections.completed.map(&:legislator)
  end

  def random_target
    (target_legislators - person.called_legislators).sample
  end

  def next_target
    (target_legislators - person.called_legislators).first
  end

end
