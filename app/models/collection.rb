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
end
