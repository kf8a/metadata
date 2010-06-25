class User < ActiveRecord::Base
  include Clearance::User

  before_save :downcase_email

  protected

  def downcase_email
    self.email = email.to_s.downcase
  end
end
