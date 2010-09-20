class User < ActiveRecord::Base
  include Clearance::User
  
  ROLES = %w[admin editor uploader]
  
  has_many :permissions
  has_many :ownerships
  has_many :datatables, :through => :ownerships

  before_save :downcase_email

  def owns?(datatable)
    self.datatables.include?(datatable)
  end
  
  def permitted?(datatable)
    datatable.permitted?(self)
  end
  
  def has_permission_from?(owner, datatable)
    permission = Permission.find_by_user_id_and_owner_id_and_datatable_id(self, owner, datatable)
    permission && permission.decision != "denied"
  end

  def denied_access?(datatable)
    !datatable.deniers_of(self).blank?
  end


  protected

  def downcase_email
    self.email = email.to_s.downcase
  end
end
