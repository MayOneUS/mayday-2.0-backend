namespace :seed do
  desc "Seed Dummy Data"
  task dummy_data: :environment do
    Legislator.recheck_reps_with_us
    campaign = Campaign.create(name: 'test campaign')
    campaign.legislators = Legislator.unconvinced.first(20)
    campaign.targets.limit(5).update_all(priority: 1)
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
  end
end