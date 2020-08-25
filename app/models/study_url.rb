# frozen_string_literal: true

# a study url is the place where there is more information about a study
class StudyUrl < ApplicationRecord
  belongs_to :study
  belongs_to :website
end
