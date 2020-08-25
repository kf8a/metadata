# frozen_string_literal: true

# Meetings can be in local, national, or other types of venues.
class VenueType < ApplicationRecord
  has_many :meetings, -> { order 'date desc' }

  validates :name, presence: true
end
