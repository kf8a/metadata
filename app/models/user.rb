class User < ActiveRecord::Base
  include Clearance::User

  before_save :downcase_email

  protected
  
  def email_optional?
    true #!self.identity_url.empty?
  end
  
  def password_optional?
    true #!self.identity_url.empty?
  end

  def downcase_email
    self.email = email.to_s.downcase
  end
end
