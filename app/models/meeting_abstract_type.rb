# An abstract presented at a local or national meeeting
class MeetingAbstractType < ActiveRecord::Base
  has_many :meeting_abstracts
end
