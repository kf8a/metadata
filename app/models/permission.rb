class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :datatable
  belongs_to :owner, :class_name => "User"
  
  validates_presence_of :user, :datatable, :owner
  validates_associated :user, :datatable, :owner
  
  validate :unique_permissions
  validate :only_owners_can_set_permissions
     
  def only_owners_can_set_permissions
    if datatable
      errors.add_to_base('owners only') unless datatable.owners.include?(owner)
    end
  end

  def unique_permissions
    if user && datatable && owner
      if Permission.count(:conditions => ['user_id = ? and datatable_id = ? and owner_id = ?', user_id, datatable_id, owner_id]) > 0
        errors.add_to_base('can only be saved once')
      end
    end
  end

end
