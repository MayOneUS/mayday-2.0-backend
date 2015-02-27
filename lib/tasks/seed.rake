namespace :seed do
  desc "Seed Dummy Data"
  task dummy_data: :environment do
    #load dummy data
  end

  desc "Purge DB of all data"
  task purge: :environment do
    DatabaseCleaner.clean_with(:truncation, :only => %w[people campaigns])
  end

  namespace :purge do
    desc "Purge DB of API generated data"
    task api: :environment do
      DatabaseCleaner.clean_with(:truncation, :only => %w[people campaigns])
    end
  end
end