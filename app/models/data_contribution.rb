class DataContribution < ActiveRecord::Base
  belongs_to :person
  belongs_to :datatable
  belongs_to :role
  
  validates_presence_of :role
end
