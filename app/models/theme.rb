class Theme < ActiveRecord::Base
  acts_as_nested_set
  
  has_and_belongs_to_many :datasets
  has_and_belongs_to_many :datatables
end
