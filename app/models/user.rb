class User < ActiveRecord::Base
  include Clearance::User
  
  has_many :permissions
  has_many :datatables, :through => :permission
  has_many :owned_datatables, :through => :ownership

  before_save :downcase_email

  protected

  def downcase_email
    self.email = email.to_s.downcase
  end
end
