class User < ActiveRecord::Base
  include Clearance::User
  
  has_many :permissions
  has_many :datatables, :through => :ownership

  before_save :downcase_email

  def allowed(datatable)
    false
  end
  protected

  def downcase_email
    self.email = email.to_s.downcase
  end
end
