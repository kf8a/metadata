# frozen_string_literal: true

# A class to hold the citation type
# so that citations can be polymorphic
class CitationType < ApplicationRecord
  has_many :citations
end
