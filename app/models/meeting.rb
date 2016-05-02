# A Meeting that was held locally or nationally
class Meeting < ActiveRecord::Base
  has_many :abstracts, -> { order :authors }
  belongs_to :venue_type

  validates :venue_type, presence: true

  def poster_abstracts
    type = MeetingAbstractType.find_by(name: 'Poster')
    abstracts.where(meeting_abstract_type_id: type.id)
  end

  def presentation_abstracts
    type = MeetingAbstractType.find_by(name: 'Presentation')
    abstracts.where(meeting_abstract_type_id: type.id)
  end
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
