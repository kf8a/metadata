# Represents a treatment that is part of a study
class Treatment < ApplicationRecord
  belongs_to :study
  has_and_belongs_to_many :citations
end
