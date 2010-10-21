class User < ActiveRecord::Base
  extend Clearance::User::ClassMethods 
  include Clearance::User::InstanceMethods 
  include Clearance::User::AttrAccessor 
  include Clearance::User::Callbacks
  
  ROLES = %w[admin editor uploader]
  
  validates_presence_of     :email, :unless => :email_optional?
  validates_uniqueness_of   :email, :case_sensitive => false, :allow_blank => true, 
        :message => "Sorry, this email account is already registered. Please sign up with a different email or <a href='/sign_in'>Sign In</a> using this email account"
  validates_format_of       :email, :with => %r{.+@.+\..+}, :allow_blank => true

  validates_presence_of     :password, :unless => :password_optional?
  validates_confirmation_of :password
  
  attr_protected :role
  
  has_many :permissions
  has_many :ownerships
  has_many :datatables, :through => :ownerships
  
  has_many :memberships
  has_many :sponsors, :through => :memberships

  before_save :downcase_email

  scope :by_email, :order => 'email'

  def owns?(datatable)
    self.datatables.include?(datatable)
  end
  
  def admin?
    role == 'admin'
  end
  
  def has_permission_from?(owner, datatable)
    permission = Permission.find_by_user_id_and_owner_id_and_datatable_id(self, owner, datatable)
    permission && permission.decision != "denied"
  end

  protected

  def downcase_email
    self.email = email.to_s.downcase
  end
end
