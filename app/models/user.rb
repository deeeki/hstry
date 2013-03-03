class User < ActiveRecord::Base
  has_many :authentications

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
end
