class Meeting < ActiveRecord::Base
  has_many :abstracts, :order => :authors
  belongs_to :venue_type
  
  validates_presence_of :venue_type
end
