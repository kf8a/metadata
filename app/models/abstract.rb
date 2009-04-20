class Abstract < ActiveRecord::Base
  set_table_name 'meeting_abstracts'
  belongs_to :meeting
end
