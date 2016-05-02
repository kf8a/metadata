# A collection as opposed to a datatable
# a collection is supposed to be browsable
class Collection < ActiveRecord::Base
  belongs_to :datatable

  validates_presence_of :datatable

  def dataset
    self.datatable.dataset
  end

  def keywords
    self.datatable.keywords
  end

  def perform_query
    datatable.perform_query
  end

  def protocols
    self.dataset.protocols
  end

  def title_and_years
    self.datatable.title_and_years
  end

  def values
    @values ||= self.perform_query
  end

  def variates
    self.datatable.variates
  end
end

# == Schema Information
#
# Table name: collections
#
#  id           :integer         not null, primary key
#  created_at   :datetime
#  updated_at   :datetime
#  datatable_id :integer
#
