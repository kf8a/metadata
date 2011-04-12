class Sponsor < ActiveRecord::Base
  has_many :datasets
  has_many :memberships
  
  has_friendly_id :name
end
