class Publication < ActiveRecord::Base
  belongs_to :publication_type
  has_many :affiliations
  has_many :people, :through => :affiliations
  has_and_belongs_to_many :treatments
  
  validates_presence_of :citation
end
