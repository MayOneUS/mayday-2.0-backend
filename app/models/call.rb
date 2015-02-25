# == Schema Information
#
# Table name: calls
#
#  id           :integer          not null, primary key
#  remote_id    :string
#  district_id  :integer
#  phone_origin :integer
#  state        :string
#  ended_at     :datetime
#  source       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Call < ActiveRecord::Base
  has_many :connections
  has_one :last_connection, -> { order 'created_at desc' }, class_name: 'Connection'
  belongs_to :zip_code
  belongs_to :person

  def create_connection!
    connections.create(legislator: random_target)
  end

  def targeted_legislators
    Legislator.limit(3).all
  end

  def called_legislators
    connections.where(state: 'completed').map(&:legislator)
  end

  def random_target
    (targeted_legislators - called_legislators).sample
  end

end
