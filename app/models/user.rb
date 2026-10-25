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

  ALLOWED = [
    "glbrc.org/GLBRC/GLBRC Groups/Y16-20/Sustainable_Bioenergy_Cropping_Systems/SEP",
    "glbrc.org\\SEP",
    "glbrc.org\\AIM-InformationServices"
  ].freeze

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      groups = Array(auth.info.id_token&.groups).compact
      old_user = User.where(email: auth.info.id_token.email).first
      logger.info "Auth info comming back #{auth}"
      if old_user
        old_user.provider = auth.provider
        old_user.uid = auth.uid
        old_user.last_glbrc_groups = groups if groups.any?
        old_user.save
      else
        user.email = auth.info.id_token.email
        user.password = Devise.friendly_token[0, 20]
        user.last_glbrc_groups = groups if groups.any?
        # group is aim-7 = member
        if groups.any? && allowed_group(groups)
          s = Sponsor.find_by(name: 'glbrc')
          user.sponsors = [s]
          user.save
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

  private

  def allowed_group(groups)
    result = ALLOWED.map do |allowed_group|
      groups.include?(allowed_group)
    end
    result.any?(true)
  end
end
