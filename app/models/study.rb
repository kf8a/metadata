class Study < ActiveRecord::Base

  has_and_belongs_to_many :datasets
  has_many :datatables
  has_many :treatments
  has_many :study_urls

  acts_as_nested_set

  scope :by_weight, -> {order 'weight' }
  scope :by_id,     -> {order 'id' }

  before_destroy :check_for_treatments

  def study_url(website)
    self.study_urls.where(:website_id => website.id).first.try(:url)
  end

  def citation_treatments
    treatments.where(:use_in_citations => true)
  end

  # returns true if one or more of the tables passed is part of the current study
  def include_datatables?(table_query = [])
    table_query = table_query.to_a  # thinking sphinks does not return an array
    (self_and_descendants_datatables & table_query).any?
  end

  def self.find_all_with_datatables(tables = [], options = {})
    all(options).keep_if { |study| study.include_datatables?(tables) }
  end

  def self.find_all_roots_with_datatables(tables=[])
    self.roots.order('weight').to_a.keep_if {|study| study.include_datatables?(tables) }
  end

  private

  def self_and_descendants_datatables
    descendants.collect {|descendant| descendant.datatables }.flatten + datatables
  end

  def check_for_treatments
    if treatments.count > 0
      errors.add(:base, 'Can not delete studies with active treatments')
      return false
    end
  end
end




# == Schema Information
#
# Table name: studies
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#  weight      :integer
#  parent_id   :integer
#  lft         :integer
#  rgt         :integer
#  synopsis    :text
#  url         :string(255)
#  code        :string(255)
#
