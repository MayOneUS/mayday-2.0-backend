json.array!(@donation_pages) do |donation_page|
  json.extract! donation_page, :slug, :visible_user_name, :rank,
    :funds_raised_in_cents
end
