class Meeting < ActiveRecord::Base
  has_many :meeting_abstracts, :order => :authors
  belongs_to :venue_type
end
