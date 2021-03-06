# frozen_string_literal: true

# Themes are used to organize datatables in the index page
class Theme < ApplicationRecord
  acts_as_nested_set

  has_and_belongs_to_many :datasets
  has_many :datatables, dependent: :nullify

  scope :by_weight, -> { order :weight }
  scope :by_name, -> { order 'name' }

  after_touch :update_parent

  def nested_name
    '-' * level + name
  end

  def datatables?(study = nil)
    i_have_datatables?(study) || children_have_datatables?(study)
  end

  def i_have_datatables?(study = nil)
    study ? datatables_in_study(study).any? : datatables.any?
  end

  def children_have_datatables?(study = nil)
    children.collect { |subtheme| subtheme.datatables?(study) }.include?(true)
  end

  def include_datatables?(test_datatables = [])
    my_datatables = self_and_descendants_datatables
    (my_datatables & test_datatables).any?
  end

  def include_datatables_from_study?(test_datatables, study)
    my_datatables = self_and_descendants_datatables
    datatables_in_study = my_datatables.collect { |table| table if table.study == study }

    (test_datatables & datatables_in_study).any?
  end

  def self_and_descendants_datatables
    my_datatables = descendants.collect(&:datatables).flatten
    my_datatables + datatables
  end

  def datatables_in_study(study, test_datatables = [])
    if test_datatables.any?
      datatables.collect do |table|
        table if table.study == study && test_datatables.include?(table)
      end.compact
    else
      datatables.collect { |table| table if table.study == study }.compact
    end
  end

  private

  def update_parent
    parent.try(:touch)
  end
end
