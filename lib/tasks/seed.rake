namespace :db do
  namespace :seed do
    desc "Seed Dummy Data"
    task dummy_data: :environment do
      ids = 'D000563', 'B001230', 'B000711', 'B000944', 'C000141', 'F000457', 'G000555', 'H000206', 'H001046', 'K000367', 'L000174', 'M000133', 'M001170', 'M000639', 'M001176', 'M001169', 'S000033', 'S001181', 'W000817', 'S001168', 'B001279', 'B001281', 'B000287', 'B001287', 'B001242', 'B000574', 'B001278', 'B001227', 'B001259', 'B001285', 'B001251', 'C001036', 'C001037', 'C001083', 'C001072', 'C001090', 'C001066', 'C001091', 'C001080', 'C001084', 'C001101', 'C001067', 'C001049', 'C001061', 'C000537', 'C001068', 'C001078', 'C000714', 'C000754', 'C001069', 'C001038', 'C000984', 'D000096', 'D000598', 'D000191', 'D000197', 'D000620', 'D000216', 'D000617', 'D000610', 'D000355', 'D000399', 'D000482', 'E000290', 'E000288', 'E000179', 'E000215', 'E000293', 'F000030', 'F000043', 'F000454', 'F000462', 'F000455', 'G000571', 'G000573', 'G000556', 'G000553', 'G000410', 'G000551', 'G000535', 'H001063', 'H001050', 'H000324', 'H001064', 'H001047', 'H001032', 'H001034', 'H001066', 'H000874', 'H001068', 'I000057', 'J000032', 'J000294', 'J000126', 'J000288', 'J000255', 'K000009', 'K000385', 'K000379', 'K000381', 'K000188', 'K000368', 'K000382', 'L000559', 'L000560', 'L000557', 'L000551', 'L000287', 'L000565', 'L000397', 'L000579', 'L000480', 'L000580', 'L000570', 'L000562', 'M001171', 'M000087', 'M001185', 'M001163', 'M001143', 'M000404', 'M000312', 'M001166', 'M001137', 'M001188', 'M001149', 'M000725', 'M001160', 'M000933', 'M001191', 'N000002', 'N000179', 'N000127', 'N000147', 'O000170', 'O000169', 'P000034', 'P000096', 'P000604', 'P000197', 'P000593', 'P000595', 'P000608', 'P000597', 'P000607', 'P000598', 'Q000023', 'R000053', 'R000576', 'R000515', 'S001156', 'S001145', 'S001162', 'S000185', 'S000248', 'S001185', 'S001170', 'S000344', 'S001165', 'S000480', 'S000510', 'S001175', 'S001193', 'T000472', 'T000460', 'T000266', 'T000469', 'T000465', 'V000128', 'V000130', 'V000132', 'V000081', 'W000799', 'W000797', 'W000215', 'W000800', 'Y000062', 'P000265', 'L000563', 'P000523', 'W000808'
      Legislator.where(bioguide_id: ids).update_all(with_us: true)
      campaign = Campaign.create(name: 'test campaign')
      campaign.legislators = Legislator.unconvinced.first(20)
      campaign.targets.limit(5).update_all(priority: 1)
      start = DateTime.parse("2015-03-14 7pm EDT").utc
      (1..7).each do |n|
        Event.create(starts_at: start + n.days,
                     ends_at:   start + 1.hour + n.days,
                     remote_id: 23 + n)
      end
    end

    desc "Purge DB of all data"
    task purge: :environment do
      DatabaseCleaner.clean_with(:truncation)
    end

    namespace :purge do
      desc "Purge DB of API generated data"
      task api: :environment do
        DatabaseCleaner.clean_with(:truncation, :only => %w[people locations])
      end
      desc "Purge DB of dummy seed data"
      task dummy_data: :environment do
        DatabaseCleaner.clean_with(:truncation, :only => %w[campaigns targets events])
      end
    end
  end
end
