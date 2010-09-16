class PermissionRequest < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :datatable
  
  validates_presence_of :user, :datatable
  
end
