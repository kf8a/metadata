class VenueType < ActiveRecord::Base
  has_many :meetings, :order => 'date desc'
end
