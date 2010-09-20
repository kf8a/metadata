class Sponsor < ActiveRecord::Base
  has_many :datasets
  
  has_many :sponsor_roles
end
