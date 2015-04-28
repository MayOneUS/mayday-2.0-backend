class V1::LegislatorsController < V1::BaseController

  SUPPORTER_MAP_REDIS_KEY = 'supports_map_json'

  def index
    render json: Legislator.with_includes
      .order(:first_name, :last_name)
      .to_json( methods: [:name, :title, :state_name, :eligible],
                only: [:id, :with_us])
  end

  def show
    legislator = Legislator.with_includes.includes(:current_bills).find_by_bioguide_id(params[:id])
    render json: legislator
      .to_json(methods: [:name, :title, :state_name, :eligible, :image_url, :state_abbrev,
                         :map_key, :current_sponsorships],
               only: [:with_us, :party, :state_rank, :in_office])
  end

  def targeted
    render json: Legislator.with_includes.targeted
  end

  def newest_supporters
    limit = params[:limit] || 5
    render json: Legislator.with_includes.joins(:sponsorships).order('sponsorships.cosponsored_at desc').first(limit)
  end

  def supporters_map
    output = redis.get(SUPPORTER_MAP_REDIS_KEY) || prep_supports_map_json
    render js: output
  end

  private

  def prep_supports_map_json
    coordinates_output = []
    Legislator.with_includes.includes(:bills,:active_campaigns).all.each_with_index do |l,i|
      next unless Legislator::MAP_COORDINATES.include?(l.map_key)
      coordinates_output << {
        map_key: l.map_key,
        coordinates: Legislator::MAP_COORDINATES[l.map_key],
        legislator: {
          name: l.name,
          title: l.title,
          party: l.party[0],
          support_max: l.support_max,
          targeted: l.targeted?,
          image_url: l.image_url,
          bioguide_id: l.bioguide_id,
          sponsorships: l.sponsorship_hash,
          chamber: l.chamber,
          description: l.support_description
        }
      }
    end
    json = Oj.dump({tile_coordinates: coordinates_output, label_coordinates: Legislator::MAP_LABELS},  mode: :compat)
    output = "onLegislatorResponse(#{json})"

    redis.set(SUPPORTER_MAP_REDIS_KEY, output)
    redis.expire(SUPPORTER_MAP_REDIS_KEY, 12.hours)

    output
  end



  def redis
    @redis ||= Redis.current
  end


end
