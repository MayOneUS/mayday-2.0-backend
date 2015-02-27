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
  belongs_to :person

  delegate :target_legislators, to: :person

  validates :person, presence: true

  CALL_STATUSES = {
    completed: 'completed',
    no_answer: 'no-answer',
    busy:      'busy',
    canceled:  'canceled',
    failed:    'failed'
  }

  def create_connection!
    connections.create(legislator: random_target)
  end

  def called_legislators
    connections.where(status: CALL_STATUSES[:completed]).map(&:legislator)
  end

  def random_target
    (target_legislators - called_legislators).sample
  end

end





