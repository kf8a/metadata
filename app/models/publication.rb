class Publication < ActiveRecord::Base
  belongs_to :publication_type
  has_many :affiliations
  has_many :people, :through => :affiliations
end
