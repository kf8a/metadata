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

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      old_user = User.where(email:auth.info.id_token.email).first
      logger.info "Auth info comming back #{auth}"
      if old_user
        old_user.provider = auth.provider
        old_user.uid = auth.uid
        old_user.save
      else
        user.email = auth.info.id_token.email
        user.password = Devise.friendly_token[0, 20]
        # group is aim-7 = member
        if !auth.info.id_tokens.nil? && auth.info.id_token.groups.contains("glbrc.org\\AIM07")
          s = Sponsor.find_by(name: 'glbrc')
          user.sponsors=[s]
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
end
