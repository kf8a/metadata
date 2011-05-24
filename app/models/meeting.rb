class Meeting < ActiveRecord::Base
  has_many :abstracts, :order => :authors
  belongs_to :venue_type

  validates_presence_of :venue_type
end


# == Schema Information
#
# Table name: meetings
#
#  id            :integer         not null, primary key
#  date          :date
#  title         :string(255)
#  announcement  :text
#  venue_type_id :integer
#  date_to       :date
#

