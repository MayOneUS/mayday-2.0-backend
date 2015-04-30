
desc "Parses CSV version of map to create map constants for Legislator.rb"
task map_parse: :environment do
  require 'csv'
  coordinates_output = {}
  labels_output = {}
  csv =  CSV.read("#{Rails.root}/app/assets/data/mayday_coordinates.csv")
  csv.each_with_index do |row,y|
    row.each_with_index do |raw_map_data,x|
      next if raw_map_data.nil?

      key,label_offset = raw_map_data.split(';')
      key += 'NIOR' if key =~ /SE|JU/
      coordinates_output[key]=[x,y]

      if label_offset
        offsets = label_offset.split(',')
        offsets = [offsets[0].to_f+x, offsets[1].to_f+y]
        labels_output[key[0,2]] = offsets
      end
    end
  end;0

  puts "MAP_COORDINATES = #{coordinates_output}"
  puts "MAP_LABELS = #{labels_output}"
end

task output_legislators: :environment do
  require 'csv'

  legislators = Legislator.with_includes.includes({sponsorships: :bill})
  bill_order = Bill.all.map{|b| b.attributes.select{|att| %w[id bill_id].include?(att) }}

  sponsorship_attr_order = Sponsorship.first.attributes.keys
  sponsorship_headers = bill_order.map{|bi| sponsorship_attr_order.map{|attribute| "#{bi['bill_id']}-#{attribute}"}}.flatten
  legislator_headers = legislators.first.attributes.keys

  def sponsorship_attrs(legislator,bill_order,sponsorship_attr_order)
    sponsorship_attributes = legislator.sponsorships.map(&:attributes)
    output = []
    bill_order.each do |bill_data|
      current_sponsorship = sponsorship_attributes.select{|s| s['bill_id'] == bill_data['id']}[0]
      output << current_sponsorship.values_at(*sponsorship_attr_order) if current_sponsorship
      puts current_sponsorship.values_at(*sponsorship_attr_order) if current_sponsorship
    end
    output.flatten
  end

  output_file = "#{Rails.root}/app/assets/data/leg_support.csv"
  CSV.open(output_file, "wb") do |csv|
    csv << legislator_headers + sponsorship_headers
    legislators.find_each do |leg|
      sponsorship_attributes = leg.sponsorships.any? ? sponsorship_attrs(leg,bill_order,sponsorship_attr_order) : []
      csv << leg.attributes.values_at(*legislator_headers) + sponsorship_attributes
    end
    csv
  end

  puts "Outputed csv to #{output_file}"

end

task lookup_bioguide_ids: :environment do
  require 'rest-client'

  targeted = [['NE',2], ['MA',6], ['MI', 14], ['FL',2], ['CA', 31], ['CA', 35], ['CA', 18], ['NY',7], ['PA', 14], ['PA',2], ['NY',8], ['MO',1], ['MO',5], ['NJ', 10], ['TX', 18], ['CA', 38], ['TX', 34], ['AZ',9], ['CA', 29], ['CA', 37], ['MA',9], ['CA',3], ['MA',1], ['MI',9], ['CA', 43], ['NV',1], ['LA',2], ['IN',1], ['GA', 13], ['CA', 46], ['CA', 36], ['TX', 28], ['NY', 26], ['CA', 16], ['MI',5], ['TX', 15], ['MN',7], ['OH', 14], ['MT',0], ['IL', 10], ['WI',6], ['NV',4], ['ME',2], ['CA', 21], ['CA', 49], ['AZ',2], ['VA',7]]

  targeted.each do |state,district|
    params =  {state: state, district: district, apikey: ENV['SUNLIGHT_KEY'], chamber: 'house'}
    query_string = URI.encode(params.map{|k,v| "#{k}=#{v}"}.join("&"))
    response = JSON.parse(RestClient.get('https://congress.api.sunlightfoundation.com/legislators?'+query_string))
    puts [state+district.to_s,response['results'][0]['bioguide_id'] ].join(',')
  end
end