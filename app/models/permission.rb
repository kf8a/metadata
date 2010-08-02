class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :datatable
  belongs_to :owner, :class_name => "User"
  
  validates_presence_of :user, :datatable, :owner
  validates_associated :user, :datatable, :owner
  
  def validate
    if datatable
      errors.add('owner') unless datatable.owners.include?(owner)
    end
  end
end
