json.user do
  json.id current_user.id
  json.name current_user.name
end
json.histories @histories, :uid, :provider, :resource, :text, :image, :url, :published_at, :location
