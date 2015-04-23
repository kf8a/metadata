class MeetingAbstractType < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :meeting_abstracts
end
