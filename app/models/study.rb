# frozen_string_literal: true

# Study is a group of experiments or an experimental location
class Study < ApplicationRecord
  has_and_belongs_to_many :datasets
  has_many :datatables, dependent: :nullify
  has_many :treatments, dependent: :nullify
  has_many :study_urls, dependent: :nullify

  acts_as_nested_set

  scope :by_weight, -> { order 'weight' }
  scope :by_id,     -> { order 'id' }

  before_destroy :check_for_treatments
  after_touch :touch_parent

  def study_url(website)
    study_urls.find_by(website_id: website.id).try(:url)
  end

  def citation_treatments
    treatments.by_use_in_citations
  end

  # check if there is more than one treatment associated with this study
  def citation_treatments?
    citation_treatments.size > 1
  end

  # returns true if one or more of the tables passed is part of the current study
  def include_datatables?(table_query = [])
    table_query = table_query.to_a # thinking sphinks does not return an array
    (self_and_descendants_datatables & table_query).any?
  end

  def self.find_all_with_datatables(tables = [])
    all.to_a.keep_if { |study| study.include_datatables?(tables) }
  end

  def self.find_all_roots_with_datatables(tables = [])
    roots.order('weight').to_a.keep_if { |study| study.include_datatables?(tables) }
  end

  private

  def self_and_descendants_datatables
    descendants.collect(&:datatables).flatten + datatables
  end

  def check_for_treatments
    if treatments.count > 0
      errors.add(:base, 'Can not delete studies with active treatments')
      false
    end
  end

  def touch_parent
    parent.try(:touch)
  end
end
