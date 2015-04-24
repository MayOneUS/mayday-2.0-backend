
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

      labels_output[key[0,2]] = label_offset.split(',').map(&:to_f) if label_offset
    end
  end;0

  puts "MAP_COORDINATES = #{coordinates_output}"
  puts "MAP_LABELS = #{labels_output}"
end
