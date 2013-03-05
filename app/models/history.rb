class History < ActiveRecord::Base
  belongs_to :user
  serialize :data
  serialize :location

  default_scope -> { order('published_at DESC') }
end
