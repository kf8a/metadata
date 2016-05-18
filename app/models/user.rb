# Members who are able to log in and do things on the site.
class User < ActiveRecord::Base
  include Clearance::User

  ROLES = %w(admin editor uploader).freeze

  validates :email, presence: true, unless: :email_optional?
  validates :email,
            allow_blank: true,
            uniqueness: { case_sensitive: false,
                          message: "Sorry, this email account is already registered. Please sign up with a different email or <a href='/sign_in'>Sign In</a> using this email account" }
  validates :email, format: %r{\A.+@.+\..+\z}, allow_blank: true

  validates :password, presence: true, unless: :password_optional?
  validates :password, confirmation: true

  has_many :permissions
  has_many :ownerships
  has_many :datatables, through: :ownerships

  has_many :memberships
  has_many :sponsors, through: :memberships

  scope :by_email, -> { order 'email' }

  def to_s
    email
  end

  def owns?(datatable)
    datatables.include?(datatable)
  end

  def admin?
    'admin' == role
  end

  def permission_from?(owner, datatable)
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
