class Event < ActiveRecord::Base
  validates :remote_id, uniqueness: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true

  after_create :post_to_nation_builder
  after_destroy :remove_from_nation_builder

  def self.create_event(start:, duration: 1)
    create(starts_at: start, ends_at: start + duration.hours)
  end

  private

  def post_to_nation_builder
    unless remote_id
      nb_args = Integration::NationBuilder.event_params(start_time: starts_at, end_time: ends_at)
      if id = Integration::NationBuilder.create_event(nb_args)
        update(remote_id: id)
      end
    end
  end

  def remove_from_nation_builder
    Integration::NationBuilder.destroy_event(remote_id)
  end

end
