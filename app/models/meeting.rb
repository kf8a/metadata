# A Meeting that was held locally or nationally
class Meeting < ApplicationRecord
  has_many :abstracts, -> { order :authors }
  belongs_to :venue_type

  validates :venue_type, presence: true

  def poster_abstracts
    by_type('Poster')
  end

  def presentation_abstracts
    by_type('Presentation')
  end

  def handouts
    by_type('Handout')
  end

  def posters_and_presentations
    poster_abstracts + presentation_abstracts
  end

  def by_type(type_name)
    type = MeetingAbstractType.find_by(name: type_name)
    abstracts.where(meeting_abstract_type_id: type.id)
  end
end
