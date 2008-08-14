class Project < ActiveRecord::Base
  has_many :datasets
end
