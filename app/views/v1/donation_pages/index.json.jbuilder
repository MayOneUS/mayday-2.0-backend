n = 1 # because jbuilder doesn't offer array_with_index
json.array!(@donation_pages) do |donation_page|
  json.extract!(donation_page, :slug, :visible_user_name, :funds_raised_in_cents)
  json.rank n
  n += 1
end
