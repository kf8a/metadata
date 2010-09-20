class Sponsor < ActiveRecord::Base
  has_many :datasets
  
  has_many :memberships
  
end
