class Event < ActiveRecord::Base
  validates :remote_id, presence: true, uniqueness: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true

  before_validation :post_to_nation_builder
  after_destroy :remove_from_nation_builder

  def self.create_event(start, duration: 1)
    create(starts_at: start, ends_at: start + duration.hours)
  end

  def self.upcoming(count = 10)
    where(starts_at: Time.now..4.weeks.from_now).order(:starts_at).limit(count)
  end

  private

  def post_to_nation_builder
    unless remote_id
      nb_args = Integration::NationBuilder.event_params(start_time: starts_at, end_time: ends_at)
      self.remote_id = Integration::NationBuilder.create_event(nb_args)
    end
  end

  def remove_from_nation_builder
    Integration::NationBuilder.destroy_event(remote_id)
  end

end
