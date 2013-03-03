Rails.application.config.middleware.use OmniAuth::Builder do
  provider :foursquare, ENV['FOURSQUARE_CONSUMER_KEY'], ENV['FOURSQUARE_CONSUMER_SECRET']
end
