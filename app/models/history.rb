class History < ActiveRecord::Base
  belongs_to :user
  serialize :data
  serialize :location
end
