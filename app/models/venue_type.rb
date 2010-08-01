class VenueType < ActiveRecord::Base
  has_many :meetings, :order => 'date desc'
  
  validates_presence_of :name
end
