class Collection < ActiveRecord::Base
  belongs_to :datatable

  validates_presence_of :datatable

  def perform_query
    query =  self.datatable.object
    ActiveRecord::Base.connection.execute(query)
  end

  def values
    @values ||= self.perform_query
  end

  def title_and_years
    self.datatable.title_and_years
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
