class User < ActiveRecord::Base
  include Clearance::User
  
  ROLES = %w[admin editor uploader]
  
  has_many :permissions
  has_many :datatables, :through => :ownership

  before_save :downcase_email

  def allowed(datatable)
    if self.role == 'admin'
      true
    elsif self.owns(datatable)
      true
    else
      false
    end
  end
  
  def owns(datatable)
    Ownership.find_by_user_id_and_datatable_id(self, datatable)
  end
  
  protected

  def downcase_email
    self.email = email.to_s.downcase
  end
end
