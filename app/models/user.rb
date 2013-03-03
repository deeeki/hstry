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

  def fetch_histories
    album = fb.get_connections('me', 'albums').select{|a| a['name'] == 'Timeline Photos' }.first
    return false unless album
    fb.get_connections(album['id'], 'photos').each do |photo|
      next if History.find_by(uid: photo['id'])
      histories.create({
        uid: photo['id'],
        provider: 'facebook',
        text: photo['name'],
        resource: 'photo',
        text: photo['name'],
        image: photo['source'],
        url: photo['link'],
        data: photo,
      })
    end
  end
end
