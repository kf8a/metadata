class Study < ActiveRecord::Base
  has_many :treatments
  has_and_belongs_to_many :datasets
end
