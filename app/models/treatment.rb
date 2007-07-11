class Treatment < ActiveRecord::Base
  has_many :plots
  belongs_to :study
  has_and_belongs_to_many :publications, :order => 'citation'
end
