class User < ActiveRecord::Base
  include Clearance::User
  
  ROLES = %w[admin editor uploader]
  
  has_many :permissions
  has_many :ownerships
  has_many :datatables, :through => :ownerships

  before_save :downcase_email

  def allowed(datatable)
    role == 'admin' or owns(datatable) or permitted(datatable)
  end
  
  def owns(datatable)
    datatables.include?(datatable)
  end
  
  def permitted(datatable)
    datatable.permitted?(self)
  end
  
  def has_permission_from(owner, datatable)
    true == Permission.find_by_user_id_and_owner_id_and_datatable_id(self, owner, datatable)
   end
  
  protected

  def downcase_email
    self.email = email.to_s.downcase
  end
end
