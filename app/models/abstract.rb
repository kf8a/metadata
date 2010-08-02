class Abstract < ActiveRecord::Base
  set_table_name 'meeting_abstracts'
  belongs_to :meeting
  
  validates_presence_of :meeting
  validates_presence_of :abstract
end
