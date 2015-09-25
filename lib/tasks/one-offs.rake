namespace :gov do
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

  task output_legislator_phone_numbers: :environment do
    require 'csv'

    output_file = "#{Rails.root}/app/assets/data/leg_phones.csv"
    legislators = Legislator.with_includes.includes({sponsorships: :bill})

    CSV.open(output_file, "wb") do |csv|
      csv << legislators.first.__send__(:serializable_hash).keys
      legislators.each do |leg|
        csv << leg.__send__(:serializable_hash).values
      end
    end

    puts "Outputed csv to #{output_file}"
  end

  desc 'lookup bioguide_ids from sunlight for a list of state_abbrev/district.'
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

  desc 'update names and pronunciation from dailykos\'s excellent 114 guide'
  task update_from_kos: :environment do
    require 'csv'

    # doc taken from https://docs.google.com/spreadsheets/d/1lGZQi9AxPHjE0RllvhNEBHFvrJGlnmC43AXnR8dwHMc/edit#gid=1978064869
    source_doc = '/db/seed_data/legislator_pronunciations.csv'

    CSV.foreach(Rails.root.to_s + source_doc, headers: true) do |csv_row|
      live_target_ids = %w[A000373 M001196 L000581 G000575 A000371 T000474 E000215 V000081 D000482 F000043 J000294 C001049 C001061 P000604 J000032 S001156 V000132 S001191 C001097 B001270 K000375 G000559 N000015 L000263 W000187 T000468 R000588 V000108 S001157 S000030 R000599 C001063 H001038 C001059 K000380 H000636 P000258 J000295 Z000018 D000613 G000576 H001070 P000611 V000129 I000056 M001197 B001290]
      state, district = csv_row['code'].split('-')
      district = '0' if district == 'AL'
      params =  {state: state, district: district, apikey: ENV['SUNLIGHT_KEY'], chamber: 'house'}
      query_string = URI.encode(params.map{|k,v| "#{k}=#{v}"}.join("&"))
      response = JSON.parse(RestClient.get('https://congress.api.sunlightfoundation.com/legislators?'+query_string))
      result = response['results'][0] && live_target_ids.include?(response['results'][0]['bioguide_id'])
      puts "#{csv_row['first_name']}, #{csv_row['last_name']}, #{csv_row['phonetic']}" if result
    end
  end

  desc 'output csv_string of potential leaders for TTH'
  task tth_output: :environment do
    require 'csv'

    fields = %w[bioguide_id party phone name title state_abbrev state_name district_code display_district image_url]
    csv_string = CSV.generate do |csv|
      csv << fields
      Legislator.with_includes.targeted.each{|l| csv << fields.map{|f| l.send(f) } }
    end
    puts csv_string
  end

end

namespace :ivr do
  desc 'print csv_string of callers to date'
  task callers_output: :environment do
    require 'csv'

    people = Person.joins(:connections).includes(:connections, :calls, location: [:state, :district]).all;0
    attributes = people.first.attributes.keys + people.first.location.attributes.keys + ['connection_count', 'completed_connections_count']
    csv_string = CSV.generate do |csv|
      csv << attributes
      people.each do |person|
        person_attrs =  person.attributes.values + person.location.attributes.values + [person.connections.length, person.connections.completed.length]
        csv <<  person_attrs
      end;0
    end;0
    puts csv_string
  end

  desc 'output csv of call recordings'
  task call_recordings_output: :environment do
    require 'open-uri'
    require 'csv'
    target_recordings = Ivr::Recording.active_recordings.compact
    attributes = %i[id name created_at file_name duration campaign_ref phone]

    csv_string = CSV.generate do |csv|
      csv << attributes
      target_recordings.each do |recording|
        file_name = [(recording.call.campaign_ref || '??').sub(/201\d{5}_/,''), '%05i' % recording.id, recording.created_at.strftime('%Y%m%d'), recording.call.person.phone ].join('_') + '.wav'
        csv << [
          recording.id,
          [recording.call.person.first_name, recording.call.person.last_name].join(' '),
          recording.created_at,
          file_name,
          recording.duration,
          recording.call.campaign_ref,
          recording.call.person.phone
        ]
        puts "storing #{recording.recording_url} as #{file_name}"
        `wget -nc -c -O #{file_name} #{recording.recording_url}`
      end;0
    end;0

    puts csv_string
  end
end
