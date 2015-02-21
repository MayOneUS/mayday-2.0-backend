connection = ActiveRecord::Base.connection

%w[states districts zip_codes districts_zip_codes legislators].each do |table|
  connection.execute(IO.read("db/seed_data/#{table}.sql"))
end

%w[states districts zip_codes legislators].each do |table|
  result = connection.execute("SELECT id FROM #{table} ORDER BY id DESC LIMIT 1")
  connection.execute(
    "ALTER SEQUENCE #{table}_id_seq RESTART WITH #{result.first['id'].to_i + 1}"
  )
end
