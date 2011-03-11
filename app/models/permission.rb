class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :datatable
  belongs_to :owner, :class_name => "User"
  
  validates_presence_of :user, :datatable, :owner
  validates_associated :user, :datatable, :owner
  
  validates_uniqueness_of :user_id, :scope => [:datatable_id, :owner_id]
  validate :only_owners_can_set_permissions

  def Permission.permitted_users
    all.collect { |permission| permission.user unless permission.denied? }.compact
  end
     
  def only_owners_can_set_permissions
    if datatable
      errors[:base] << 'owners only' unless datatable.owners.include?(owner)
    end
  end

  def denied?
    decision == "denied"
  end
end
