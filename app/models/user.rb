# frozen_string_literal: true

# Members who are able to log in and do things on the site.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :timeoutable,
         :omniauthable, omniauth_providers: [:glbrc]

  ROLES = %w[admin editor uploader].freeze

  has_many :permissions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :ownerships, dependent: :destroy

  has_many :datatables, through: :ownerships

  has_many :sponsors, through: :memberships

  scope :by_email, -> { order 'email' }

  # Identity provider groups whose members get GLBRC data access on first sign-in
  ALLOWED = [
    'glbrc.org/GLBRC/GLBRC Groups/Y16-20/Sustainable_Bioenergy_Cropping_Systems/SEP',
    'glbrc.org\\AIM-InformationServices'
  ].freeze

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      old_user = User.where(email: auth.info.id_token.email).first
      logger.info "Auth info comming back #{auth}"
      if old_user
        old_user.provider = auth.provider
        old_user.uid = auth.uid
        old_user.save
      else
        user.email = auth.info.id_token.email
        user.password = Devise.friendly_token[0, 20]
        # group is aim-7 = member
        if allowed_group?(auth.info.id_token.groups)
          glbrc = Sponsor.find_by(name: 'glbrc')
          user.sponsors = [glbrc] if glbrc
        end
        user.save
      end
    end
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

  def permission_from?(owner, datatable)
    permission = permissions.find_by(owner_id: owner, datatable_id: datatable)
    permission && !permission.denied?
  end

  def self.allowed_group?(groups)
    Array(groups).intersect?(ALLOWED)
  end
  private_class_method :allowed_group?
end
