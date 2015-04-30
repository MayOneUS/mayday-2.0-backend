class V1::LegislatorsController < V1::BaseController

  def index
    json = Rails.cache.fetch("legislators#index", expires_in: 12.hours) do
      Legislator.with_includes.includes(:sponsorships, :bills).includes(:current_bills)
        .order(:first_name, :last_name)
        .to_json( methods: [:name, :title, :state_name, :eligible, :image_url, :state_abbrev,
          :with_us, :display_district],
          only: [:id, :with_us, :party, :bioguide_id])
    end
    expires_in 6.hours, :public => true
    render js: json
  end

  def show
    json = Rails.cache.fetch("legislators#show?bioguide_id=#{params[:bioguide_id]}", expires_in: 12.hours) do
      Legislator.with_includes.includes(:current_bills).find_by_bioguide_id(params[:bioguide_id])
        .to_json(methods: [:name, :title, :state_name, :eligible, :image_url, :state_abbrev,
                           :map_key, :current_sponsorships, :with_us, :display_district],
                 only: [:party, :state_rank, :in_office, :bioguide_id, :id, :twitter_id, :facebook_id])
    end
    expires_in 6.hours, :public => true
    render json: json
  end

  def targeted
    render json: Legislator.with_includes.targeted
  end

  def newest_supporters
    limit = params[:limit] || 5
    json = Rails.cache.fetch("legislators#index?limit=#{limit}", expires_in: 12.hours) do
      Legislator.with_includes.includes({sponsorships: :bill}, :bills)
        .where('sponsorships.id IS NOT NULL').distinct.merge(Bill.current)
        .order('sponsorships.cosponsored_at desc').first(limit)
      end
    render json: json
  end

  def supporters_map
    json = Rails.cache.fetch("legislators#supporters_map", expires_in: 12.hours) do
      prep_supports_map_json
    end
    render js: json
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

    output
  end



  def redis
    @redis ||= Redis.current
  end


end
