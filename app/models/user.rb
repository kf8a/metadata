# frozen_string_literal: true

# Members who are able to log in and do things on the site.
class User < ApplicationRecord
  # Include default devise modules. Others available are: :confirmable
  devise :database_authenticatable, :lockable, :validatable,
         :recoverable, :rememberable, :trackable, :timeoutable, :invitable,
         :omniauthable, omniauth_providers: [:glbrc]

  # An admin creating an account for a new reader gives their name and institution (PermissionsController)
  validates :first_name, :last_name, :institution, presence: true, on: :invite_reader

  ROLES = %w[admin editor uploader].freeze
  MEMBER_TIMEOUT = 4.hours

  has_many :permissions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :ownerships, dependent: :destroy

  has_many :datatables, through: :ownerships

  has_many :sponsors, through: :memberships

  scope :by_email, -> { order 'email' }

  ALLOWED = [
    "glbrc.org/GLBRC/GLBRC Groups/Y16-20/Sustainable_Bioenergy_Cropping_Systems/SEP",
    "glbrc.org\\SEP",
    "glbrc.org\\AIM-InformationServices"
  ].freeze

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      groups = Array(auth.info.id_token&.groups).compact
      old_user = User.where(email: auth.info.id_token.email).first
      if old_user
        # Signing in with GLBRC proves the address, so it completes an account an admin created for them
        if old_user.invited_to_sign_up?
          old_user.password = Devise.friendly_token[0, 20]
          old_user.accept_invitation!
        end
        old_user.provider = auth.provider
        old_user.uid = auth.uid
        old_user.last_glbrc_groups = groups if groups.any?
        old_user.save
        return old_user # the account that is signed in, not the unsaved record looked up by provider and uid
      else
        user.email = auth.info.id_token.email
        user.password = Devise.friendly_token[0, 20]
        user.last_glbrc_groups = groups if groups.any?
        # group is aim-7 = member
        if allowed_group?(groups)
          glbrc = Sponsor.find_by(name: 'glbrc')
          user.sponsors = [glbrc] if glbrc
        end
        user.save
      end
    end
  end

  def name
    [first_name, last_name].compact_blank.join(' ').presence
  end

  # The password is set when the invitation is accepted, not by the admin who creates the account
  def password_required?
    return false if validation_context == :invite_reader

    super
  end

  def to_s
    email
  end

  def owns?(datatable)
    datatables.include?(datatable)
  end

  def admin?
    role == 'admin'
  end

  # Devise :timeoutable. Admins get the configured timeout (Devise.timeout_in); everyone else
  # is signed out sooner.
  def timeout_in
    admin? ? super : MEMBER_TIMEOUT
  end

  def self.allowed_group?(groups)
    Array(groups).intersect?(ALLOWED)
  end
  private_class_method :allowed_group?
end
