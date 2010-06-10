class Sponsor < ActiveRecord::Base
  has_many :datasets
  has_and_belongs_to_many :protocols
end
