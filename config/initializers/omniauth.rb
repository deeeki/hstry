Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  provider :facebook, ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'],
    scope: 'email,user_photos,read_stream'
  provider :foursquare, ENV['FOURSQUARE_CLIENT_ID'], ENV['FOURSQUARE_CLIENT_SECRET']
  provider :instagram, ENV['INSTAGRAM_CLIENT_ID'], ENV['INSTAGRAM_CLIENT_SECRET']
end
