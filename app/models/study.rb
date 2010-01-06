class Study < ActiveRecord::Base
  has_many :treatments
  has_many :datasets
end
