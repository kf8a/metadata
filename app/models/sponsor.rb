class Sponsor < ActiveRecord::Base
  has_many :datasets
end
