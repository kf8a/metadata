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
  
  protected

  def downcase_email
    self.email = email.to_s.downcase
  end
end
