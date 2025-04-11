# frozen_string_literal: true

# Represents a treatment that is part of a study
class Treatment < ApplicationRecord

  acts_as_nested_set

  belongs_to :study
  has_and_belongs_to_many :citations

  scope :by_use_in_citations, -> { where(use_in_citations: true) }
  scope :with_tree_order, -> {order(:lft)}

  def self.select_options
    Treatment.all.map { |t| option_for(t)}
  end

  def self.select_options_by_use_in_citations
    Treatment.by_use_in_citations.map { |t| option_for(t)}
  end

  def self.select_options_by_study(study_id)
    Treatment.where(study_id: study_id).map { |t| option_for(t)}
  end

  def self.option_for(treatment)
    display_name = if treatment.name == treatment.description
        treatment.name
      else
        "#{treatment.name} #{treatment.description}"
      end
      [display_name, treatment.id]
  end

  def has_citations?
    # if the treatment or it's children have citations return true
    return true if citations.any?
    children.each do |child|
      return true if child.has_citations?
    end
    false
  end

  def display_name
    self.parent ? "#{self.parent.description} > #{self.name} #{self.description}" : "#{self.name} #{self.description}"
  end
end
