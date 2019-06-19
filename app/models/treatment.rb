# frozen_string_literal: true

# Represents a treatment that is part of a study
class Treatment < ApplicationRecord
  belongs_to :study
  has_and_belongs_to_many :citations

  scope :by_use_in_citations, -> { where(use_in_citations: true) }
end
