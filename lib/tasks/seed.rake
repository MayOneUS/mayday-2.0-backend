namespace :db do
  namespace :seed do
    desc "Seed Dummy Data"
    task dummy_data: :environment do
      campaign = Campaign.create(name: "TEST campaign #{Time.now.strftime("%Y-%m-%d")}")
      # ids = %w[M001196 B001296 A000373 T000474 A000371 L000581 E000215 P000604 F000043 J000032 S001156 C001066 C001049 D000482 C001097 G000571 C001061 J000294 G000575 N000188 V000081 V000132]
      ids = ["T000193", "B000490", "L000563", "G000559", "K000380", "L000263", "D000623", "V000108", "H001038", "C001063", "R000599"] #fake targets from 04/17
      campaign.legislators = Legislator.where(bioguide_id: ids)
      campaign.targets.limit(5).update_all(priority: 1)
      start = DateTime.parse("2017-05-14 7pm EDT").utc
      (1..5).each do |n|
        Event.create(starts_at: start + n.days,
                     ends_at:   start + 1.hour + n.days,
                     remote_id: 25 + n)
      end

      %w[hr20-114 hr424-114].each do |bill_id|
        Bill.fetch(bill_id: bill_id)
      end

      puts "You now have #{Legislator.targeted.length} targeted legislators"
    end

    desc "Reset reps with us"
    task reps_with_us: :environment do
      ids = ["N000127", "R000515", "O000170", "N000002", "L000582", "M000087", "L000580", "K000368", "T000472", "T000473", "S001185", "B000911", "D000096", "B001251", "V000128", "S001168", "Q000023", "M001160", "D000399", "S001175", "R000053", "M001163", "M000404", "M001166", "P000607", "D000598", "D000623", "D000622", "P000096", "D000620", "D000610", "D000624", "R000602", "F000030", "B000574", "P000608", "J000288", "I000057", "L000397", "H001047", "L000480", "S000185", "W000822", "N000147", "K000188", "C001067", "J000126", "C001069", "C001068", "M001191", "L000570", "B001278", "L000579", "F000454", "C001101", "G000574", "D000216", "S000248", "C001072", "N000179", "M001188", "S001180", "M001185", "C001078", "L000560", "L000562", "L000565", "B000287", "P000034", "F000462", "S000480", "B001292", "D000197", "P000523", "D000191", "D000617", "H000874", "C001080", "C001084", "C001083", "G000535", "L000559", "M001137", "S001145", "L000557", "L000551", "R000486", "T000465", "K000379", "L000287", "G000410", "B001281", "Y000062", "B001285", "B001286", "B001287", "G000556", "G000553", "G000551", "P000597", "C000537", "P000593", "T000460", "C001090", "C001091", "P000197", "H001063", "W000808", "H001064", "H001068", "E000179", "R000577", "R000576", "S000344", "C000984", "C000714", "J000255", "E000293", "K000385", "E000290", "K000382", "K000381", "V000131", "H001034", "H000324", "F000455", "S001165", "M000312", "W000799", "P000598", "W000797", "K000009", "W000800", "B001227", "E000288", "T000469", "C000754", "A000370", "V000130", "C001038", "C001036", "C001037", "S001193", "M001143", "S000510"]
      Legislator.where.not(bioguide_id: ids).update_all(with_us: false)
      Legislator.where(bioguide_id: ids).update_all(with_us: true)
    end

    desc "seed actions"
    task activities: :environment do
      %w[sign-up-form call-congress volunteer-form sign-letter join-discussion spread-the-word].each do |template_id|
        Activity.create(template_id: template_id)
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