class Treatment < ActiveRecord::Base
  belongs_to :study
  has_and_belongs_to_many :publications, :order => 'citation'
end
