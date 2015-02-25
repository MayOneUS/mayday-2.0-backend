if @user
  json.target_legislators(@user.target_legislators_json)
  json.address_required(@user.address_required?)
else
  json.error('user not found')
end
