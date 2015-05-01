namespace :db do
  namespace :seed do
    desc "Seed All Dummy Data"
    task dummy: [:dummy_campaign, :bills, :dummy_events, :activities]
    task live: [:bills, :live_targets, :activities]

    desc "Seed a fake campaign"
    task dummy_campaign: :environment do
      campaign = Campaign.create(name: "TEST campaign #{Time.now.strftime("%Y-%m-%d")}")
      # ids = %w[M001196 B001296 A000373 T000474 A000371 L000581 E000215 P000604 F000043 J000032 S001156 C001066 C001049 D000482 C001097 G000571 C001061 J000294 G000575 N000188 V000081 V000132]
      ids = ["T000193", "B000490", "L000563", "G000559", "K000380", "L000263", "D000623", "V000108", "H001038", "C001063", "R000599"] #fake targets from 04/17
      campaign.legislators = Legislator.where(bioguide_id: ids)
      campaign.targets.limit(5).update_all(priority: 1)

      puts "You now have #{Legislator.targeted.length} targeted legislators"
    end

    desc "Seed fake events"
    task dummy_events: :environment do
      start = DateTime.parse("2017-05-14 7pm EDT").utc
      (1..5).each do |n|
        Event.create(starts_at: start + n.days, ends_at: start + 1.hour + n.days, remote_id: 25 + n)
      end
    end

    desc "Seed tracked bill data (from sunlight)"
    task bills: :environment do
      puts 'Adding bills...'
      Bill::TRACKED_BILL_IDS.each do |bill_id|
        Bill.fetch(bill_id: bill_id)
      end
    end

    desc "add live targets"
    task live_targets: :environment do
      puts 'Getting latest sunlight data..'
      Legislator.fetch_all

      puts "Adding a Campaign and targeted Legislators..."
      campaign = Campaign.create(name: "20150501 campaign")
      live_target_ids = %w[A000373 M001196 L000581 G000575 A000371 T000474 E000215 V000081 D000482 F000043 J000294 C001049 C001061 P000604 J000032 S001156 V000132 S001191 C001097 B001270 K000375 G000559 N000015 L000263 W000187 T000468 R000588 V000108 S001157 S000030 R000599 C001063 H001038 C001059 K000380 H000636 P000258 J000295 Z000018 D000613 G000576 H001070 P000611 V000129 I000056 M001197 B001290]
      campaign.legislators = Legislator.where(bioguide_id: live_target_ids)
      puts "You now have #{Legislator.targeted.length} targeted legislators. It should be 47."

    end

    desc "seed actions"
    task activities: :environment do
      %w[sign-up-form sign-letter-form get-educated spread-the-word call-congress join-discussion volunteer-form].each_with_index do |template_id, index|
        Activity.create(template_id: template_id, sort_order: index, name: template_id.gsub('-',' '))
      end
    end
  end

  desc "Purge DB of all data"
  task purge: :environment do
    DatabaseCleaner.clean_with(:truncation)
  end

  namespace :purge do
    desc "Purge DB of API generated data"
    task api: :environment do
      DatabaseCleaner.clean_with(:truncation, :only => %w[people locations calls connections actions])
    end
    desc "Purge DB of dummy seed data"
    task dummy_data: :environment do
      DatabaseCleaner.clean_with(:truncation, :only => %w[campaigns targets events])
    end
    desc "Purge DB of extra states (e.g., Puerto Rico)"
    task extra_states: :environment do
      State.where("id > ?", 51).each { |state| state.destroy }
    end
  end
end