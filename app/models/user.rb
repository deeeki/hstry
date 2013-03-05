class User < ActiveRecord::Base
  has_many :authentications
  has_many :histories

  class << self
    def from_omniauth auth
      if authentication = Authentication.find_by(provider: auth.provider, uid: auth.uid)
        return authentication.user
      end
      transaction do
        user = User.create!(name: auth.info.name || auth.info.first_name)
        user.add_authentication_from_omniauth(auth)
        user
      end
    end
  end

  def add_authentication_from_omniauth auth
    if authentication = Authentication.find_by(provider: auth.provider, uid: auth.uid)
      unless user_id == authentication.user_id
        transaction do
          authentication.user.destroy
          authentication.update_attributes!(user_id: user_id)
        end
      end
      return authentication
    end
    authentications.create!({
      provider: auth.provider,
      uid: auth.uid,
      name: auth.info.name || auth.info.first_name,
      email: auth.info.email,
      image: auth.info.image,
      token: auth.credentials.token,
      secret: auth.credentials.secret,
    })
  end

  def fb
    return @fb if @fb
    auth = authentications.select{|a| a.provider == 'facebook' }.first
    @fb = Koala::Facebook::API.new(auth.token)
  end

  def tw
    return @tw if @tw
    auth = authentications.select{|a| a.provider == 'twitter' }.first
    @tw = Twitter::Client.new(oauth_token: auth.token, oauth_token_secret: auth.secret)
  end

  def fs
    return @fs if @fs
    auth = authentications.select{|a| a.provider == 'foursquare' }.first
    @fs = Foursquare2::Client.new(oauth_token: auth.token, api_version: '20130303')
  end

  def ig
    return @ig if @ig
    auth = authentications.select{|a| a.provider == 'instagram' }.first
    @ig = Instagram.client(access_token: auth.token)
  end

  def fetch_histories provider
    __send__(:"fetch_histories_from_#{provider}")
  end

  def fetch_histories_from_facebook
    album = fb.get_connections('me', 'albums').select{|a| a['name'] == 'Timeline Photos' }.first
    return false unless album
    fb.get_connections(album['id'], 'photos').each do |photo|
      next if History.find_by(uid: photo['id'])
      histories.create({
        uid: photo['id'],
        provider: 'facebook',
        text: photo['name'],
        resource: 'photo',
        image: photo['source'],
        url: photo['link'],
        published_at: photo['created_time'],
        data: photo,
      })
    end
  end

  def fetch_histories_from_twitter
    max_id = nil
    16.times do # retrieving limit is 200 * 16
      tw.user_timeline({count: 200, max_id: max_id}.reject{|k,v| v.nil? }).each do |tweet|
        max_id = tweet.id
        next if tweet.media.empty?
        next if tweet.retweet?
        photo = tweet.media.first
        next if History.find_by(uid: photo.id)
        histories.create({
          uid: photo.id,
          provider: 'twitter',
          text: tweet.text,
          resource: 'photo',
          image: photo.media_url,
          url: photo.expanded_url,
          published_at: tweet.created_at,
          data: tweet.to_hash,
        })
      end
    end
  end

  def fetch_histories_from_foursquare
    fs.user_checkins(limit: 250).items.each do |checkin|
      next if checkin.photos.count.zero? || checkin.photos.items.empty?
      photo = checkin.photos.items.first
      next unless photo.source.url.include?('foursquare')
      next if History.find_by(uid: checkin.id)
      image = "#{photo.prefix}#{photo.width}x#{photo.height}#{photo.suffix}"
      histories.create({
        uid: checkin.id,
        provider: 'foursquare',
        text: checkin.shout,
        resource: 'checkin',
        image: image,
        url: checkin.venue.canonicalUrl,
        published_at: Time.at(checkin.createdAt),
        location: {
          name: checkin.venue.name,
          address: checkin.venue.location.country,
          latitude: checkin.venue.location.lat,
          longtitude: checkin.venue.location.lng,
        },
        data: checkin.to_hash,
      })
    end
  end

  def fetch_histories_from_instagram
    ig.user_recent_media(count: 40).each do |photo|
      next if History.find_by(uid: photo.id)
      if photo.location
        location = {
          name: photo.location.name,
          latitude: photo.location.latitude,
          longtitude: photo.location.longitude,
        }
      end
      histories.create({
        uid: photo.id,
        provider: 'instagram',
        text: photo.caption.text,
        resource: 'image',
        image: photo.images.standard_resolution.url,
        url: photo.link,
        published_at: Time.at(photo.created_time.to_i),
        location: location,
        data: photo.to_hash,
      })
    end
  end
end
