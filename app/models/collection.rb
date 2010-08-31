class Collection < ActiveRecord::Base
  belongs_to :datatable
  
  validates_presence_of :datatable
end
