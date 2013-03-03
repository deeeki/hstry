class User < ActiveRecord::Base
  has_many :authentications

  class << self
    def find_or_create_from_auth_hash auth
      if authentication = Authentication.find_by(provider: auth.provider, uid: auth.uid)
        return authentication.user
      end
      name = auth.info.name || auth.info.first_name
      transaction do
        user = User.create!(name: name)
        user.authentications.create!({
          provider: auth.provider,
          uid: auth.uid,
          name: name,
          email: auth.info.email,
          image: auth.info.image,
          token: auth.credentials.token,
          secret: auth.credentials.secret,
        })
        user
      end
    end
  end
end
