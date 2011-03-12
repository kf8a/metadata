# Meetings can be in local, national, or other types of venues.
class VenueType < ActiveRecord::Base
  has_many :meetings, :order => 'date desc'

  validates_presence_of :name
end
