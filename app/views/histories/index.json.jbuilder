json.array!(@histories) do |history|
  json.extract! history, :user_id, :uid, :provider, :resource, :text, :image, :url, :published_at, :location, :data
  json.url history_url(history, format: :json)
end
