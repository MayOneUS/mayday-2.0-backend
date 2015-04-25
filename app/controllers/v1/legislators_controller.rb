class V1::LegislatorsController < V1::BaseController

  def index
    render json: Legislator.with_includes
      .order(:first_name, :last_name)
      .to_json( methods: [:name, :title, :state_name, :eligible],
                only: [:id, :with_us])
  end

  def show
    legislator = Legislator.with_includes.find_by_bioguide_id(params[:id])
    render json: legislator
      .to_json( methods: [:name, :title, :state_name, :eligible, :image_url, :state_abbrev], only: [:with_us, :party])
  end

  def targeted
    render json: Legislator.with_includes.targeted
  end

  def newest_supporters
    render json: Legislator.with_includes.joins(:sponsorships).order('sponsorships.cosponsored_at desc').all
  end

  def supporters_map
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
    json = {tile_coordinates: coordinates_output, label_coordinates: Legislator::MAP_LABELS}.to_json
    render js: "onLegislatorResponse(#{json})"
  end

end
