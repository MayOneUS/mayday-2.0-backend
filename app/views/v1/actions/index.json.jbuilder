json.count @activity.actions.count
json.current_page @actions.current_page
json.total_pages @actions.total_pages
json.limit @actions.per_page
json.(@activity, :strike_total_in_cents)
json.results @actions, partial: 'action', as: :action
