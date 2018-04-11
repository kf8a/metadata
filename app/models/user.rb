# Members who are able to log in and do things on the site.
class User < ApplicationRecord
  include Clearance::User

  ROLES = %w(admin editor uploader).freeze

  validates :email, presence: true, unless: :email_optional?
  validates :email,
            allow_blank: true,
            uniqueness: { case_sensitive: false,
                          message: 'Sorry, this email account is already registered.'\
                                   ' Please sign up with a different email'\
                                   " or <a href='/sign_in'>Sign In</a> using this email account" }
  validates :email, format: /\A.+@.+\..+\z/, allow_blank: true

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
    permission = permissions.find_by(owner_id: owner, datatable_id: datatable)
    permission && !permission.denied?
  end
end
