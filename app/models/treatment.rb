# frozen_string_literal: true

# Represents a treatment that is part of a study
class Treatment < ApplicationRecord

  acts_as_nested_set

  belongs_to :study
  has_and_belongs_to_many :citations

  scope :by_use_in_citations, -> { where(use_in_citations: true) }

  def self.select_options
    Treatment.all.map { |t| ["#{t.name} #{t.description}", t.id] }
  end

  def self.select_options_by_use_in_citations
    Treatment.by_use_in_citations.map { |t| ["#{t.name} #{t.description}", t.id] }
  end

  def self.select_options_by_study(study_id)
    Treatment.where(study_id: study_id).map { |t| ["#{t.name} #{t.description}", t.id] }
  end
end
