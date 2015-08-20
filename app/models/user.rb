# Members who are able to log in and do things on the site.
class User < ActiveRecord::Base
  include Clearance::User

  ROLES = %w[admin editor uploader]

  validates_presence_of     :email, :unless => :email_optional?
  validates_uniqueness_of   :email, :case_sensitive => false, :allow_blank => true,
      :message => "Sorry, this email account is already registered. Please sign up with a different email or <a href='/sign_in'>Sign In</a> using this email account"
  validates_format_of       :email, :with => %r{\A.+@.+\..+\z}, :allow_blank => true

  validates_presence_of     :password, :unless => :password_optional?
  validates_confirmation_of :password

  # attr_protected :role, :identity_url

  has_many :permissions
  has_many :ownerships
  has_many :datatables, :through => :ownerships

  has_many :memberships
  has_many :sponsors, :through => :memberships

  scope :by_email, -> {order 'email'}

  def to_s
    self.email
  end

  def owns?(datatable)
    self.datatables.include?(datatable)
  end

  def admin?
    'admin' == role
  end

  def has_permission_from?(owner, datatable)
    permission = permissions.find_by_owner_id_and_datatable_id(owner, datatable)
    permission && !permission.denied?
  end

end




# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  email              :string(255)
#  encrypted_password :string(128)
#  salt               :string(128)
#  confirmation_token :string(128)
#  remember_token     :string(128)
#  email_confirmed    :boolean         default(FALSE), not null
#  created_at         :datetime
#  updated_at         :datetime
#  identity_url       :string(255)
#  role               :string(255)
#

