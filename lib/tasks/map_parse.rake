
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
  bill_order = Bill.all.map{|b| b.attributes.select{|att| %w[id bill_id].include?(att) }

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
