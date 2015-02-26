if @error
  json.error(@error)
else
  json.target_legislators(@user.target_legislators(json: true))
  json.address_required(@user.address_required?)
end
