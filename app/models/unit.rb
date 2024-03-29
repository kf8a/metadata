# frozen_string_literal: true

# A unit in the EML sense. Connects to variates
class Unit < ApplicationRecord
  has_many :variates, dependent: :nullify

  after_find :update_job
  #  after_find :update_dictionary
  scope :not_in_eml, -> { where 'in_eml is false' }

  def human_name
    label.try(:html_safe)
  end

  def update_job
    # Delayed::Job.enqueue UnitUpdateJob.new(self)
  end

  def update_dictionary
    # Delayed::Job.enqueue UnitDictionaryUpdateJob.new(self)
  end
end

# scenarios
# 1) we need a list of available units
#   Unit.all
#     return units on hand
#     and then query in the background for more units

# 2) we need to retrieve a particular unit
#   Unit.find
#
