class Ownership < ActiveRecord::Base
  belongs_to :user
  belongs_to :datatable
  
  validates_presence_of :user
  validates_presence_of :datatable
end
