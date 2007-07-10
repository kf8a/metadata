class Treatment < ActiveRecord::Base
  has_many :plots
  has_and_belongs_to_many :publications
end
